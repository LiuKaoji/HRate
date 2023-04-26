//
//  BPMViewModel.swift
//  HRate
//
//  Created by kaoji on 4/14/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Charts

class BPMViewModel: NSObject {
    // MARK: - Properties
    // BPMTracker 相关属性
    private let tracker: BPMTracker
    let charData: BehaviorRelay<[Int]> = .init(value: []) // 图表数据（可观察）
    let workData: Observable<WorkoutData>  // 手表实时数据

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
    let videoButtonTapped = PublishSubject<Void>() // 历史按钮点击事件
    
    // 导航和错误处理相关属性
    var navigateToNextScreen: ((UIViewController) -> Void)? // 导航到下一个页面的闭包
    var presentScreen: ((UIViewController) -> Void)? // 弹出页面闭包
    var trackerCauseError: ((Error) -> Void)? // 心率追踪器错误处理闭包
    
   
    
    // MARK: - 初始化
    override init() {
        self.tracker = BPMTracker.shared
        self.recoder = Recorder()
        
        recordButtonEnabled = recordButtonEnabledSubject.asObservable()
        workData = tracker.workoutData.asObservable().filter { $0 != nil }.map { $0! }
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
        let list = AEPlayerController()
        navigateToNextScreen?(list)
    }
    
    private func handleVideoButtonTapped() {
        let userInfo = UserInfoFormViewController()
        presentScreen?(userInfo)
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
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.handleHistoryButtonTapped()
            })
            .disposed(by: disposeBag)
        
        videoButtonTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.handleVideoButtonTapped()
            })
            .disposed(by: disposeBag)
//
//        // 心率监听状态
//        tracker.state.subscribe { state in
//        }
//        .disposed(by: disposeBag)

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
        }
        .disposed(by: disposeBag)

        // 心率数据回调
        tracker.workoutData.filter { $0 != nil }.map { $0! }.subscribe { [weak self] data in
            if let workData = data.element, let stSelf = self {
                var desc = BPMDescription()
                desc.set(with: workData)
                desc.ts = stSelf.recoder.currentTime
                stSelf.bpmArray.append(desc)
                stSelf.charData.accept(workData.bpmData)
            }
        }
        .disposed(by: disposeBag)
    }
}

