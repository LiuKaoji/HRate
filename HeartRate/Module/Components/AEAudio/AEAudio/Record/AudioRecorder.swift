//
//  AudioRecorder.swift
//  AEAudio
//
//  Created by kaoji on 5/4/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

@objc public enum AudioRecordStatus: Int {
    case idle = 0
    case prepared
    case recording
    case stopped
    case errorOccured
}

@objc public protocol AudioRecordable: AnyObject {
    @objc optional func audioRecorder(_ audioRecorder: AudioRecorder, didChangedStatus status: AudioRecordStatus)
    @objc optional func audioRecorder(_ audioRecorder: AudioRecorder, didFinishedWithUrl url: URL, duration: TimeInterval, fileSize: UInt64)
    @objc optional func audioRecorder(_ audioRecorder: AudioRecorder, didUpdateCurrentTime currentTime: TimeInterval)
    @objc optional func audioRecorder(_ audioRecorder: AudioRecorder, didUpdateDecibel decibel: Float)
    @objc optional func audioRecorderPermissionDenied(_ audioRecorder: AudioRecorder)
}

@objc public class AudioRecorder: NSObject {
    public var currentTime: TimeInterval {
        return currentSampleTime
    }
    public var voiceIOPowerMeter = PowerMeter()
    public var isRecording = false
    public var isDenied = false
    private var avAudioEngine = AVAudioEngine()
    private var recordedFile: AVAudioFile?
    private var voiceIOFormat: AVAudioFormat
    private(set) var currentSampleTime: Double = 0
    private var timer: DispatchSourceTimer?

    
    
    public weak var delegate: AudioRecordable?
    
    public override init() {
        voiceIOFormat = avAudioEngine.inputNode.outputFormat(forBus: 0)
        super.init()
        

    }
    
    public func startRecord(url: URL) {
        guard !isRecording else { return }

        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
               guard let self = self else { return }
               
               if allowed {
                   self.isDenied = false
                   startLogic()
               } else {
                   self.isDenied = true
                   // Notify delegate that permission was denied
                   DispatchQueue.main.async {
                       self.delegate?.audioRecorderPermissionDenied?(self)
                   }
               }
           }
        
        // 内嵌函数 注意使用
        func startLogic(){
            
            do {
                try self.avAudioEngine.start()
            } catch {
                print("Could not start audio engine: \(error)")
                self.delegate?.audioRecorder?(self, didChangedStatus: .errorOccured)
                return
            }
            
            currentSampleTime = 0
            NotificationCenter.default.addObserver(self, selector: #selector(handleAppCrash), name: UIApplication.willTerminateNotification, object: nil)
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: voiceIOFormat.sampleRate,
                AVNumberOfChannelsKey: voiceIOFormat.channelCount,
                AVEncoderBitRateKey: 256000 // 指定比特率（以位/秒为单位）
            ]
            do {
                recordedFile = try AVAudioFile(forWriting: url, settings: settings)
                isRecording = true
                delegate?.audioRecorder?(self, didChangedStatus: .recording)
            } catch {
                print("Could not create file for recording: \(error)")
                delegate?.audioRecorder?(self, didChangedStatus: .errorOccured)
            }
            
            let input = avAudioEngine.inputNode
            input.installTap(onBus: 0, bufferSize: 256, format: voiceIOFormat) { [weak self] buffer, when in
                guard let self = self else { return }
                if self.isRecording {
                    do {
                        try self.recordedFile?.write(from: buffer)
                        self.currentSampleTime += Double(buffer.frameLength) / buffer.format.sampleRate
                        self.voiceIOPowerMeter.process(buffer: buffer)
                    } catch {
                        print("Could not write buffer: \(error)")
                        self.voiceIOPowerMeter.processSilence()
                    }
                    
                }
            }
            
            self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            self.timer?.schedule(deadline: .now(), repeating: .seconds(1))
            self.timer?.setEventHandler { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.delegate?.audioRecorder?(self, didUpdateCurrentTime: self.currentSampleTime)
                }
            }
            self.timer?.resume()
        }
    }
    
    public func stopRecord() {
        guard isRecording else { return }
        avAudioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
        delegate?.audioRecorder?(self, didChangedStatus: .stopped)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let recordedFileURL = self.recordedFile?.url
            self.avAudioEngine.stop()
            self.avAudioEngine.reset()
            self.recordedFile = nil
            DispatchQueue.main.async {
                if let fileURL = recordedFileURL, FileManager.default.fileExists(atPath: fileURL.path) {
                    let info = AudioInfo.init(url: fileURL)
                    let duration = info.duration
                    let fileSize = info.fileSize
                    self.delegate?.audioRecorder?(self, didFinishedWithUrl: fileURL, duration: duration, fileSize: fileSize)
                    self.recordedFile = nil
                }
            }
            
            timer?.cancel()
            timer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }


    @objc private func handleAppCrash() {
        if isRecording {
            stopRecord()
        }
    }
    
    public func destroy() {
        stopRecord()
        avAudioEngine.stop()
        avAudioEngine.reset()
    }
}
