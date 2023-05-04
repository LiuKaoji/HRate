//
//  BPMViewModel.swift
//  HRate
//
//  Created by kaoji on 4/14/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import Charts
import AEAudio
import AVFAudio

class BPMViewModel: NSObject {
    // MARK: - Properties
    // BPMTracker 相关属性
    private let tracker: BPMTracker
    let charData: BehaviorRelay<[Int]> = .init(value: []) // 图表数据（可观察）
    let workData: Observable<WorkoutData>  // 手表实时数据

    // Recorder 相关属性
    private var recoder: AudioRecorder?
    private let disposeBag = DisposeBag() // 处理订阅的Dispose Bag
    private var audioET: AudioEntity?
    private var bpmArray: [BPMDescription] = []
    
    let time = BehaviorRelay<String>(value: "--:--") // 录音时间
    public let isRecording = BehaviorRelay<Bool>(value: false) // 是否正在录制

    // 录制按钮相关属性
    private let recordButtonEnabledSubject = BehaviorSubject<Bool>(value: true)
    let recordButtonEnabled: Observable<Bool> // 录制按钮可用状态（可观察）
    let recordButtonTapped = PublishSubject<Void>() // 录制按钮点击事件
    let levelProvider = PublishSubject<AudioLevelProvider?>() // 历史按钮点击事件

    // 历史按钮相关属性
    let historyButtonTapped = PublishSubject<Void>() // 历史按钮点击事件
    let userInfoButtonTapped = PublishSubject<Void>() // 历史按钮点击事件
    
    // 导航和错误处理相关属性
    var navigateToPlayScreen: (() -> Void)? // 导航到下一个页面的闭包
    var presentScreen: ((UIViewController) -> Void)? // 弹出页面闭包
    var trackerCauseError: ((Error) -> Void)? // 心率追踪器错误处理闭包
    
   
    
    // MARK: - 初始化
    override init() {
        self.tracker = BPMTracker.shared
        recordButtonEnabled = recordButtonEnabledSubject.asObservable()
        workData = tracker.workoutData.asObservable().filter { $0 != nil }.map { $0! }
        super.init()
        
        setupSubscriptions()
    }
    
    // MARK: - 录制开关
    private func startRec() {
        isRecording.accept(true)
        tracker.startHandle()
    }
    
    private func stopRec() {
        isRecording.accept(false)
        tracker.stopHandle()
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
            isRuning ?self?.startRecorder():self?.stopRecorder()
        }
    }
    
    private func handleHistoryButtonTapped() {
        navigateToPlayScreen?()
    }
    
    private func handleuserInfoButtonTapped() {
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
        
        userInfoButtonTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.handleuserInfoButtonTapped()
            })
            .disposed(by: disposeBag)
//
//        // 心率监听状态
//        tracker.state.subscribe { state in
//        }
//        .disposed(by: disposeBag)

       

        // 心率数据回调
        tracker.workoutData.filter { $0 != nil }.map { $0! }.subscribe { [weak self] data in
            if let workData = data.element, let stSelf = self {
                var desc = BPMDescription()
                desc.set(with: workData)
                desc.ts = stSelf.recoder?.currentTime ?? 0
                stSelf.bpmArray.append(desc)
                stSelf.charData.accept(workData.bpmData)
            }
        }
        .disposed(by: disposeBag)
    }
    

    func startRecorder(){
        guard recoder == nil else { return }
        AVAudioSession.switchToRecordMode()
        let new: AudioEntity = PersistManager.shared.newAudioEntity()//建立新的实体
        let newURL = new.audioURL()//获取预先设计好的录制路径
        
        recoder = AudioRecorder()
        recoder?.startRecord(url: newURL)
        PersistManager.shared.insertAudio(audioEntity: new)
        if recoder?.isDenied == false{
            isRecording.accept(true)
            tracker.startHandle()
            levelProvider.on(.next(recoder?.voiceIOPowerMeter))
        }
        
        recoder?.rx.currentTime.subscribe { [weak self] currentTime in
            self?.time.accept(TimeFormat.formatTimeInterval(seconds: currentTime))
        }
        .disposed(by: disposeBag)
        
        recoder?.rx.denied.subscribe(onNext: { _ in
            
        })
        .disposed(by: disposeBag)
        
        recoder?.rx.finish.subscribe(onNext: { [weak self] url, duration, fileSize in
            if let model = self?.audioET {
                model.duration = TimeFormat.formatTimeInterval(seconds: duration)
                model.size = toByteString(UInt64(fileSize))
                model.bpms = self?.bpmArray ?? []
                PersistManager.shared.insertAudio(audioEntity: model)
            }
            self?.audioET = nil
            self?.bpmArray.removeAll()
        })
        .disposed(by: disposeBag)
    }
    
    func stopRecorder(){
        guard recoder != nil else { return }
        recoder?.stopRecord()
        recoder?.destroy()
        recoder = nil
        isRecording.accept(false)
        tracker.stopHandle()
        AVAudioSession.switchToAmbient()
        levelProvider.on(.next(nil))
    }
}

