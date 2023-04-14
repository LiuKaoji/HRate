//
//  BPMViewModel.swift
//  HeartRate
//
//  Created by kaoji on 4/14/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Charts

class BPMViewModel: NSObject {
    // MARK: - Properties
    // BPMTracker 相关属性
    private let tracker: BPMTracker
    let nowBPM: Observable<String>        // 当前心率（可观察）
    let minBPM: Observable<String>        // 最小心率（可观察）
    let maxBPM: Observable<String>        // 最大心率（可观察）
    let avgBPM: Observable<String>        // 平均心率（可观察）
    let charData: Observable<BarChartData> // 图表数据（可观察）
    let progress: Observable<Double>      // 心率百分比（可观察）

    // Recorder 相关属性
    private let recoder: Recorder
    private let disposeBag = DisposeBag() // 处理订阅的Dispose Bag
    private var audioET: AudioEntity?
    private var bpmArray: [BPMDescription] = []
    
    let time = BehaviorRelay<String>(value: "--:--") // 录音时间
    public let isRecording = BehaviorRelay<Bool>(value: false) // 是否正在录制

    // 录制按钮相关属性
    private let recordButtonEnabledSubject = BehaviorSubject<Bool>(value: true)
    let recordButtonEnabled: Observable<Bool> // 录制按钮可用状态（可观察）
    let recordButtonTapped = PublishSubject<Void>() // 录制按钮点击事件

    // 历史按钮相关属性
    let historyButtonTapped = PublishSubject<Void>() // 历史按钮点击事件

    // 导航和错误处理相关属性
    var navigateToNextScreen: ((UIViewController) -> Void)? // 导航到下一个页面的闭包
    var trackerCauseError: ((Error) -> Void)? // 心率追踪器错误处理闭包
    
    // MARK: - 初始化
    override init() {
        self.tracker = BPMTracker.shared
        self.recoder = Recorder()
        
        recordButtonEnabled = recordButtonEnabledSubject.asObservable()
        
        nowBPM = tracker.nowBPM.asObservable().map { "\($0)" }
        minBPM = tracker.minBPM.asObservable().map { "\($0)" }
        maxBPM = tracker.maxBPM.asObservable().map { "\($0)" }
        avgBPM = tracker.avgBPM.asObservable().map { "\($0)" }
        progress = tracker.bpmPercent.asObservable().map { $0 }
        
        charData = tracker.bpmData.asObservable().map { bpms -> BarChartData in
            var entries = [BarChartDataEntry]()
            for i in 0..<bpms.count {
                entries.append(BarChartDataEntry(x: Double(i), y: Double(bpms[i])))
            }
            let set = BarChartDataSet(entries: entries)
            let data = BarChartData(dataSet: set)
            set.colors = [UIColor(named: "Color")!]
            return data
        }
        
        super.init()
        
        setupSubscriptions()
    }
    
    // MARK: - 录制开关
    private func startRec() {
        isRecording.accept(true)
        tracker.startHandle()
        audioET = PersistManager.shared.newAudioEntity()
        recoder.setupRecorder(identify: (audioET!.name!))
        recoder.startRecording()
    }
    
    private func stopRec() {
        isRecording.accept(false)
        tracker.stopHandle()
        recoder.stopRecording()
        time.accept("--:--")
    }
    
    // MARK: - 按钮事件处理
    private func handleRecordButtonTapped() {

        recordButtonEnabledSubject.onNext(false)
        tracker.toggleRunning { [weak self] error in
            self?.recordButtonEnabledSubject.onNext(true)
            
            if let error = error {
                self?.trackerCauseError?(error)
                self?.stopRec()
                return
            }
            print("state: \(self!.tracker.state.value)")
            let isRuning = (self?.tracker.state.value == .running)
            isRuning ?self?.startRec():self?.stopRec()
        }
    }
    
    private func handleHistoryButtonTapped() {
        let list = AudioListTableViewController()
        navigateToNextScreen?(list)
    }
    
    // MARK: - 订阅事件
    private func setupSubscriptions() {
        // 录制按钮点击事件
        recordButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.handleRecordButtonTapped()
            })
            .disposed(by: disposeBag)

        // 历史按钮
        historyButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.handleHistoryButtonTapped()
            })
            .disposed(by: disposeBag)

        // 心率监听状态
        tracker.state.subscribe { state in
        }
        .disposed(by: disposeBag)

        // 音频录制中
        recoder.recording.subscribe { [weak self](durationStr, decibel) in
            self?.time.accept(durationStr)
        }
        .disposed(by: disposeBag)

        // 音频录制完成
        recoder.recordCompleted.subscribe { [weak self] (fileURL, durationStr, sizeStr) in
            if let model = self?.audioET, let bpms = self?.bpmArray {
                model.duration = durationStr
                model.size = sizeStr
                model.bpms = bpms
                PersistManager.shared.insertAudio(audioEntity:  model)
            }
            self?.audioET = nil
            self?.bpmArray.removeAll()
            self?.tracker.reset()
        }
        .disposed(by: disposeBag)

        // 心率数据回调
        tracker.dataHandle.subscribe { [weak self] (bpm: Int16, date: String) in
            guard let stSelf = self, let isRecording = self?.recoder.isRecording, isRecording else { return }
            var desc = BPMDescription()
            desc.bpm = bpm
            desc.date = date
            desc.ts = stSelf.recoder.currentTime
            stSelf.bpmArray.append(desc)
        }
        .disposed(by: disposeBag)
    }
}

