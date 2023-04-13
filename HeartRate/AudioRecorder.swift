//
//  Recorder.swift
//  HeartRate
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import AVFoundation

enum RecorderState {
    case ready
    case recording
    case paused
}

class Recorder: NSObject, AVAudioRecorderDelegate {
    
    public var identify = "" // 每次录音的唯一标识
    private var isAuthorized: Bool = false //是否授权录音
    private var recorder: AVAudioRecorder? //
    private var recordURL: URL? //
    private var timer: Timer?
    private var startTime: Date?
    private var meteringUpdateInterval = 0.1
    private(set) var state: RecorderState = .ready
    public var currentTime: TimeInterval {
        get{
            recorder?.currentTime ?? .zero
        }
    }
    
    typealias RecordingCallback = (_ seconds: String, _ decibel :Int64) -> Void
    typealias RecordFinishCallback = (_ recordURL: URL, _ duration: String, _ size: String) -> Void
    
    var recordingHandle: RecordingCallback?
    var recordedHandle: RecordFinishCallback?
   
    
    override init() {
        super.init()
        setupRecorder()
    }
    
    private func setupRecorder() {
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        
        switch session.recordPermission {
        case .granted:
            isAuthorized = true
        case .denied, .undetermined:
            isAuthorized = false
            requestAuthorization()
        default:
            break
        }
        
        let url = getAudioFileURL()
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
    }
    
    private func requestAuthorization() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            self.isAuthorized = granted
        }
    }
    
    private func getAudioFileURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "REC - \(CTZDateFormatter.shared.currentDateString()).m4a"
        return documentsPath.appendingPathComponent(fileName)
    }
    
    func startRecording() {
        startTime = Date()
        recorder?.prepareToRecord()
        recorder?.record()
        state = .recording
        
        timer = Timer.scheduledTimer(timeInterval: meteringUpdateInterval, target: self, selector: #selector(updateMetering), userInfo: nil, repeats: true)
    }
    
    @objc private func updateMetering() {
        recorder?.updateMeters()
        let time = TimeInterval(recorder?.currentTime ?? 0)
        let db = Double(recorder?.averagePower(forChannel: 0) ?? -160)
        let decibel: Int64 = Int64(pow(10.0, db / 20.0))
        
        let durationStr = CTZDateFormatter.formatTimeInterval(seconds: time)
        recordingHandle?(durationStr, decibel)
    }
    
    func pauseRecording() {
        recorder?.pause()
        state = .paused
        timer?.invalidate()
    }
    
    func cancelRecording() {
        recorder?.stop()
        recorder?.deleteRecording()
        timer?.invalidate()
    }
    
    func stopRecording() {
        recorder?.stop()
        timer?.invalidate()
        
    }
    
    func resumeRecording() {
        if state == .paused {
            recorder?.record()
            state = .recording
            
            timer = Timer.scheduledTimer(timeInterval: meteringUpdateInterval, target: self, selector: #selector(updateMetering), userInfo: nil, repeats: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let duration = recorder.currentTime
            let fileURL = recorder.url
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[FileAttributeKey.size] as? UInt64) ?? 0
            
            let durationStr = CTZDateFormatter.formatTimeInterval(seconds: duration)
            let sizeStr = toByteString(fileSize)
            recordedHandle?(fileURL, durationStr, sizeStr)
        }
    }
    
     func toByteString(_ size: UInt64) -> String {
        var convertedValue = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}
