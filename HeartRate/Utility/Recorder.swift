//
//  Recorder.swift
//  HeartRate
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

enum RecorderState {
    case ready
    case recording
    case paused
}

class Recorder: NSObject, AVAudioRecorderDelegate {
    
    // 每次录音的唯一标识
    public var identify = TimeFormat.shared.currentDateString()
    // 是否授权录音
    private var isAuthorized: Bool = false
    // 录音器
    private var recorder: AVAudioRecorder?
    // 录音文件的URL
    private var recordURL: URL?
    // 计时器
    private var timer: Timer?
    // 开始录音的时间
    private var startTime: Date?
    // 更新计时器的间隔
    private var meteringUpdateInterval = 0.1
    // 录音器的状态
    private(set) var state: RecorderState = .ready
    // 当前录音时间
    public var currentTime: TimeInterval {
        get {
            recorder?.currentTime ?? .zero
        }
    }
    
    public var stopTime: TimeInterval = .zero
    
    // 是否正在录音
    public var isRecording: Bool {
        get {
            recorder?.isRecording ?? false
        }
    }
    
    // 录音数据的发布主题
    let recording = PublishSubject<(String, Int64)>()
    // 录音完成数据的发布主题
    let recordCompleted = PublishSubject<(URL, String, String)>()
    
    private let disposeBag = DisposeBag()
    
    
    override init() {
        super.init()
    
    }
    
    // 设置录音器
    public func setupRecorder(identify: String) {
        self.identify = identify
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .allowBluetoothA2DP)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        
        // 检查录音权限
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
    
    // 请求录音权限
    private func requestAuthorization() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            self.isAuthorized = granted
        }
    }
    
    // 获取录音文件的URL
    private func getAudioFileURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(identify)"
        return documentsPath.appendingPathComponent(fileName)
    }
    
    // 开始录音
    func startRecording() {
        startTime = Date()
        recorder?.prepareToRecord()
        recorder?.record()
        state = .recording
        
        timer = Timer.scheduledTimer(timeInterval: meteringUpdateInterval, target: self, selector: #selector(updateMetering), userInfo: nil, repeats: true)
    }
    
    // 更新录音计时器
    @objc private func updateMetering() {
        recorder?.updateMeters()
        let time = TimeInterval(recorder?.currentTime ?? 0)
        let db = Double(recorder?.averagePower(forChannel: 0) ?? -160)
        let decibel: Int64 = Int64(pow(10.0, db / 20.0))
        
        let durationStr = TimeFormat.formatTimeInterval(seconds: time)
        recording.onNext((durationStr, decibel))
    }
    
    // 暂停录音
    func pauseRecording() {
        recorder?.pause()
        state = .paused
        timer?.invalidate()
    }
    
    // 取消录音
    func cancelRecording() {
        recorder?.stop()
        recorder?.deleteRecording()
        timer?.invalidate()
    }
    
    // 停止录音
    func stopRecording() {
        stopTime = recorder?.currentTime ?? .zero
        recorder?.stop()
        timer?.invalidate()
    }
    
    // 继续录音
    func resumeRecording() {
        if state == .paused {
            recorder?.record()
            state = .recording
            
            timer = Timer.scheduledTimer(timeInterval: meteringUpdateInterval, target: self, selector: #selector(updateMetering), userInfo: nil, repeats: true)
        }
    }
    
    // 录音完成
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let duration = stopTime
            let fileURL = recorder.url
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[FileAttributeKey.size] as? UInt64) ?? 0
            
            let durationStr = TimeFormat.formatTimeInterval(seconds: duration)
            let sizeStr = toByteString(fileSize)
            recordCompleted.onNext((fileURL, durationStr, sizeStr))
        }
    }
    
    // 将文件大小转换为可读字符串
    func toByteString(_ size: UInt64) -> String {
        var convertedValue = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}
