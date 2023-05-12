//
//  AudioPlayer.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import Foundation
import AVFoundation
import Accelerate
import UIKit
import MediaPlayer

@objc public protocol AudioPlayerDelegate: AnyObject {
    @objc optional func player(_ player: AudioPlayer, didChangeStatus status: AudioPlayerStatus)
    @objc optional func player(_ player: AudioPlayer, didUpdateTime currentTime: TimeInterval)
    @objc optional func player(_ player: AudioPlayer, didUpdateDuration duration: TimeInterval)
    @objc optional func player(_ player: AudioPlayer, didUpdateFrequencyData data: [[Float]])
    @objc optional func player(_ player: AudioPlayer, didFailWithError error: AudioPlayerError)
    @objc optional func player(_ player: AudioPlayer, didUpdateCoverImage image: UIImage)
    @objc optional func playerDidHandleNext()
    @objc optional func playerDidHandlePrevious()
}

@objc public class AudioPlayer: NSObject {
    private var isAppActive = true
    
    public  var totalTime: TimeInterval = .zero
    private var sourceFile: AVAudioFile?
    private var format: AVAudioFormat?
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private let timePitchNode = AVAudioUnitTimePitch()
    private var audioPlayerNodeTimer: OSTimer?
    private var currentAudioFramePosition: AVAudioFramePosition = 0
    private var totalAudioFrameLength: AVAudioFramePosition = 0
    private let fftSize: Int = 1024
    private var fftSetup: FFTSetup?
    public var analyzer: RealtimeAnalyzer!
    public var playable: AudioPlayable?
    
    public static let shared = AudioPlayer()
    public weak var delegate: AudioPlayerDelegate?
    
    public var fileSampleRate: Double = 44100
    
    public var status: AudioPlayerStatus = .idle {
        didSet {
            delegate?.player?(self, didChangeStatus: status)
        }
    }
    
    public var duration: TimeInterval {
        TimeInterval(totalAudioFrameLength) / fileSampleRate
    }
    
    public var currentTime: TimeInterval {
        TimeInterval(currentAudioFramePosition) / fileSampleRate
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
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)

        setupRemoteCommandCenter()
    }
    
    deinit {
        teardownRemoteCommandCenter()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)

    }
}

// MARK: private
private extension AudioPlayer {
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
            guard let fileSampleRate = self?.fileSampleRate else {
                return
            }
            let convertedCount = Double(buffer.frameLength) * (fileSampleRate / buffer.format.sampleRate)
            strongSelf.currentAudioFramePosition += AVAudioFramePosition(convertedCount)
            
            DispatchQueue.global(qos: .userInitiated).async {
                if strongSelf.isAppActive {
                    let spectra = strongSelf.analyzer.analyse(with: buffer)
                    strongSelf.delegate?.player?(strongSelf, didUpdateFrequencyData: spectra)
                }
            }
        }
    }
    
    func prepareAudioFile(with url: URL) {
        do {
            sourceFile = try AVAudioFile(forReading: url)
        } catch {
            delegate?.player?(self, didFailWithError: .fileReadingError)
            return
        }
        format = sourceFile?.processingFormat
        fileSampleRate = sourceFile?.fileFormat.sampleRate ?? 44100.0
        guard let sourceFile = sourceFile else {
            return
        }
        let convertedFrameLength = Double(sourceFile.length) * (fileSampleRate / Double(sourceFile.fileFormat.sampleRate))
        totalAudioFrameLength = AVAudioFramePosition(convertedFrameLength)
        status = .prepared
        
        let totalTime = Double(totalAudioFrameLength) / fileSampleRate
        self.totalTime = totalTime
        delegate?.player?(self, didUpdateDuration: duration)
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
            delegate?.player?(self, didFailWithError: .audioEngineError)
            print(AudioPlayerError.audioEngineError.message)
            return
        }
        audioPlayerNode.play()
    }
    
    @objc func updateAudioPlayerNodeValue() {
        let isFinished = currentAudioFramePosition >= totalAudioFrameLength
        if isFinished {
            stop()
            status = .finished // 设置状态为播放完成
        }
        
        let currentTime = Double(currentAudioFramePosition) / fileSampleRate
        delegate?.player?(self, didUpdateTime: currentTime)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    }
    
    func addAudioPlayerNodeTimer() {
        audioPlayerNodeTimer = OSTimer.init(loop: 1.0, timerCallback: { loop in
            self.updateAudioPlayerNodeValue()
        })
        audioPlayerNodeTimer?.start()
    }
}

// MARK: public
extension AudioPlayer {
    public func play(with playable: AudioPlayable) {
        guard let audioURL = playable.audioURL() else {
            return
        }
        if status != .stopped {
            stop()
        }
        prepareAudioFile(with: audioURL)
        scheduleFile()
        startEngine()
        status = .playing
        addAudioPlayerNodeTimer()
        self.playable = playable
        updateNowPlayingInfo()
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
        let seekToTime = max(currentTime - seconds, 0)
        seek(to: seekToTime)
    }
    
    public func seek(to time: Double) {
        guard let sourceFile = sourceFile else {
            return
        }
        
        let wasPlaying = audioPlayerNode.isPlaying
        audioPlayerNode.stop()
        
        let seekToTime = min(max(0, time), duration)
        currentAudioFramePosition = AVAudioFramePosition(seekToTime * fileSampleRate)
        
        updateAudioPlayerNodeValue()
        
        let startingFrame = AVAudioFramePosition(seekToTime * sourceFile.fileFormat.sampleRate)
        let frameCount = AVAudioFrameCount(sourceFile.length - startingFrame)
        
        // 检查是否还有frame可以调度
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
        audioPlayerNodeTimer?.stop()
        audioEngine.pause()
        audioPlayerNode.pause()
        
        status = .paused
    }
    
    public func stop() {
        audioPlayerNodeTimer?.stop()
        
        audioEngine.stop()
        audioEngine.reset()
        
        audioPlayerNode.stop()
        audioPlayerNode.reset()
        currentAudioFramePosition = 0
        
        status = .stopped
    }
    
    // 当应用进入后台时调用
    @objc private func appDidEnterBackground() {
        isAppActive = false  // 设置应用的状态为非活跃
    }
    
    // 当应用即将进入前台时调用
    @objc private func appWillEnterForeground() {
        isAppActive = true  // 设置应用的状态为活跃
    }
    
    // 更新正在播放的信息
    private func updateNowPlayingInfo() {
        guard let info = self.playable else { return }
        
        let currentTime = Double(currentAudioFramePosition) / fileSampleRate
        
        // 创建包含播放信息的字典
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: info.audioName(),
            MPMediaItemPropertyPlaybackDuration: info.audioDuration(),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime
        ]
        
        // 如果 info.coverImage 非空，则创建 MPMediaItemArtwork 对象并添加到 nowPlayingInfo 字典中
        let image = self.getCoverImage()
        if let coverImage = image {
            let artwork = MPMediaItemArtwork(boundsSize: coverImage.size) { _ in
                return coverImage
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            delegate?.player?(self, didUpdateCoverImage: coverImage)
        }
        
        // 更新播放信息
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // 设置远程命令中心
    private func setupRemoteCommandCenter() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 添加播放命令
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }
        
        // 添加暂停命令
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // 添加下一曲命令
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            self.delegate?.playerDidHandleNext?()
            return .success
        }
        
        // 添加上一曲命令
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            self.delegate?.playerDidHandlePrevious?()
            return .success
        }
        
        // 添加改变播放位置命令
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: event.positionTime)
                return .success
            }
            return .success
        }
    }
    
    // 解构远程命令中心
    private func teardownRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        // 移除所有命令
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
        // 清空正在播放信息
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // 获取封面图像
     private func getCoverImage() -> UIImage? {
         guard let info = self.playable, let url = info.audioURL() else {
             return nil  // 如果没有可播放的信息或者音频URL为空，则返回nil
         }
         let asset = AVURLAsset.init(url: url)  // 使用音频URL初始化AVURLAsset对象
         let metadata = asset.metadata(forFormat: AVMetadataFormat.id3Metadata)  // 获取音频元数据
         for item in metadata {
             if let key = item.commonKey, key.rawValue == "artwork", let imageData = item.dataValue {
                 // 如果找到了封面图像，使用图像数据创建并返回UIImage对象
                 return UIImage(data: imageData)
             }
         }

         // 如果没有从音频元数据中找到封面图片，尝试从 framework 中加载 cover.png
         let bundle = Bundle(for: AudioPlayer.self)
         if let imageURL = bundle.url(forResource: "cover", withExtension: "png") {
             return UIImage(contentsOfFile: imageURL.path)
         }

         return nil
     }

    // 处理音频会话中断
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // 音频会话中断开始，例如电话呼入
            // 这里你可以暂停播放器，或者执行其他相关操作
            pause()
        case .ended:
            // 音频会话中断结束
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 恢复播放
                    resume()
                }
            }
        @unknown default:
            break
        }
    }
}
