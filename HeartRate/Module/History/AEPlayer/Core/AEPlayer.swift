//
//  AEPlayer.swift
//  HRate
//
//  Created by kaoji on 2021/07/25.
//

import Foundation
import AVFoundation
import Accelerate
import UIKit

@objc public protocol AudioPlayable: AnyObject {
    @objc optional func player(_ player: AEPlayer, didChangedStatus status: AEPlayerStatus)
    @objc optional func player(_ player: AEPlayer, didUpdateCurrentTime currentTime: TimeInterval)
    @objc optional func player(_ player: AEPlayer, didUpdateTotalTime total: TimeInterval)
    @objc optional func player(_ player: AEPlayer, didUpdatefrequencyData data: [Float])
    @objc optional func player(_ player: AEPlayer, didUpdateAudioFileInfo info: String)
}

@objc public class AEPlayer: NSObject {
    private var isAppActive = true
    
    public  var totalTime: TimeInterval = .zero
    private var sourceFile: AVAudioFile?
    private var format: AVAudioFormat?
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private let timePitchNode = AVAudioUnitTimePitch()
    private var audioPlayerNodeTimer: Timer?
    private var currentAudioFramePosition: AVAudioFramePosition = 0
    private var totalAudioFrameLength: AVAudioFramePosition = 0
    private let fftSize: Int = 2048
    private var fftSetup: FFTSetup?
    public var analyzer: RealtimeAnalyzer!
    
    public static let shared = AEPlayer()
    public weak var delegate: AudioPlayable?
    
    public let defaultSampleRate: Double = 44100
    
    public var status: AEPlayerStatus = .idle {
        didSet {
            delegate?.player?(self, didChangedStatus: status)
        }
    }
    
    public var duration: TimeInterval {
        TimeInterval(totalAudioFrameLength) / defaultSampleRate
    }
    
    public var currentTime: TimeInterval {
        TimeInterval(currentAudioFramePosition) / defaultSampleRate
    }
    
    public var pitch: Float {
        get {
            timePitchNode.pitch
        }
        set {
            timePitchNode.pitch = newValue
        }
    }
    
    public var pitchEnabled: Bool {
        get {
            timePitchNode.bypass == false
        }
        set {
            timePitchNode.bypass = !newValue
        }
    }
    
    private override init() {
        super.init()
        setupEngine()
        pitchEnabled = false
        fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Float(fftSize))), FFTRadix(kFFTRadix2))
        configureAudioSession()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetoothA2DP)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

// MARK: private
private extension AEPlayer {
    func setupEngine() {
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(timePitchNode)
        
        let nodes: [AVAudioNode] = [audioPlayerNode, timePitchNode, audioEngine.mainMixerNode]
        for count in 0..<nodes.count - 1 {
            audioEngine.connect(nodes[count], to: nodes[count + 1], format: format)
        }
        
        analyzer = RealtimeAnalyzer(fftSize: fftSize)
        
        audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(fftSize), format: audioEngine.mainMixerNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
            guard let strongSelf = self else { return }
            guard let defaultSampleRate = self?.defaultSampleRate else {
                return
            }
            let convertedCount = Double(buffer.frameLength) * (defaultSampleRate / buffer.format.sampleRate)
            strongSelf.currentAudioFramePosition += AVAudioFramePosition(convertedCount)
            
            DispatchQueue.global(qos: .userInitiated).async {
                if strongSelf.isAppActive {
                    let spectra = strongSelf.analyzer.analyse(with: buffer)
                    strongSelf.delegate?.player?(strongSelf, didUpdatefrequencyData: spectra)
                }
            }
        }
    }
    
    func prepareAudioFile(with url: URL) {
        sourceFile = try? AVAudioFile(forReading: url)
        format = sourceFile?.processingFormat
        
        guard let sourceFile = sourceFile else {
            return
        }
        let convertedFrameLength = Double(sourceFile.length) * (defaultSampleRate / Double(sourceFile.fileFormat.sampleRate))
        totalAudioFrameLength = AVAudioFramePosition(convertedFrameLength)
        status = .prepared
        
        let totalTime = Double(totalAudioFrameLength) / defaultSampleRate
        self.totalTime = totalTime
        delegate?.player?(self, didUpdateTotalTime: totalTime)
        
        updateAudioFileInfo()
        
    }
    
    func updateAudioFileInfo() {
        guard let sourceFile = sourceFile else { return }
        let fileSize = sourceFile.length
        let sampleRate = sourceFile.fileFormat.sampleRate
        let bitRate = UInt32(sourceFile.processingFormat.streamDescription.pointee.mBitsPerChannel)
        let channelCount = sourceFile.fileFormat.channelCount
        let channelInfo = channelCount == 1 ? "mono" : "stereo"
        
        let info = String(format: "%dkbps %.1fKHz %@", bitRate, sampleRate/1000, channelInfo)
        delegate?.player?(self, didUpdateAudioFileInfo: info)
    }
    
    func scheduleFile() {
        guard let sourceFile = sourceFile else {
            return
        }
        audioPlayerNode.scheduleFile(sourceFile, at: nil)
    }
    
    func startEngine() {
        do {
            try audioEngine.start()
        } catch {
            print(AEPlayerError.audioEngineError.message)
            return
        }
        audioPlayerNode.play()
    }
    
    @objc func updateAudioPlayerNodeValue() {
        let isFinished = currentAudioFramePosition >= totalAudioFrameLength
        if isFinished {
            stop()
        }
        
        let currentTime = Double(currentAudioFramePosition) / defaultSampleRate
        delegate?.player?(self, didUpdateCurrentTime: currentTime)
    }
    
    func addAudioPlayerNodeTimer() {
        audioPlayerNodeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioPlayerNodeValue), userInfo: nil, repeats: true)
    }
    
    func disableOfflineRendering() {
        audioPlayerNode.stop()
        audioEngine.stop()
    }
}

// MARK: public
extension AEPlayer {
    public func play(with url: URL) {
        if status != .stopped {
            stop()
        }
        prepareAudioFile(with: url)
        scheduleFile()
        startEngine()
        status = .playing
        addAudioPlayerNodeTimer()
    }
    
    public func resume() {
        // 如果音频已经播放完毕，则将播放位置重置到音频的起点
        if currentTime >= duration ||  currentTime == 0 {
            seek(to: 0)
        }
        try? audioEngine.start()
        audioPlayerNode.play()
        status = .playing
        addAudioPlayerNodeTimer()
    }
    
    public func skipForward(seconds: Double) {
        let seekToTime = currentTime + seconds
        seek(to: seekToTime)
    }
    
    public func skipBackward(seconds: Double) {
        let seekToTime = currentTime - seconds
        seek(to: seekToTime)
    }
    
    public func seek(to time: Double) {
        guard let sourceFile = sourceFile else {
            return
        }
        
        
        
        let wasPlaying = audioPlayerNode.isPlaying
        audioPlayerNode.stop()
        
        let seekToTime = min(max(0, time), duration)
        currentAudioFramePosition = AVAudioFramePosition(seekToTime * defaultSampleRate)
        
        updateAudioPlayerNodeValue()
        
        let startingFrame = AVAudioFramePosition(seekToTime * sourceFile.fileFormat.sampleRate)
        let frameCount = AVAudioFrameCount(sourceFile.length - startingFrame)
        
        // Check if there are any frames left to schedule
        if frameCount > 0 {
            audioPlayerNode.scheduleSegment(
                sourceFile,
                startingFrame: startingFrame,
                frameCount: frameCount,
                at: nil
            )
        }
        
        if wasPlaying {
            if !audioEngine.isRunning {
                try? audioEngine.start()
            }
            
            audioPlayerNode.play()
        }
    }
    
    public func pause() {
        audioPlayerNodeTimer?.invalidate()
        audioEngine.pause()
        audioPlayerNode.pause()
        
        status = .paused
    }
    
    public func stop() {
        audioPlayerNodeTimer?.invalidate()
        
        audioEngine.stop()
        audioEngine.reset()
        
        audioPlayerNode.stop()
        audioPlayerNode.reset()
        currentAudioFramePosition = 0
        
        status = .stopped
    }
    
    @objc private func appDidEnterBackground() {
        isAppActive = false
    }
    
    @objc private func appWillEnterForeground() {
        isAppActive = true
    }
}
