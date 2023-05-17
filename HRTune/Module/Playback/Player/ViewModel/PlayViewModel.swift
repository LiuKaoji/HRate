//
//  PlayViewModel.swift
//  HRTune
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio
import AVFAudio

enum PlayAction {
    case previous
    case next
    case random
    case current
}

class BasePlayViewModel {
    
    // Inputs
    let togglePlay = PublishSubject<Void>()
    let toggleBack = PublishSubject<Void>()
    let toggleForward = PublishSubject<Void>()
    let toggleMode = PublishSubject<Void>()
    let toggleList = PublishSubject<Void>()
    let sliderDown = PublishSubject<Void>()
    let sliderInside = PublishSubject<Void>()
    let sliderCancel = PublishSubject<Void>()
    let sliderOutside = PublishSubject<Void>()
    let sliderChanged = PublishSubject<Float>()
    
    // Outputs
    let outTitle = BehaviorRelay(value: "")//播放器标题
    let outFileDesc = BehaviorRelay(value: "")//文件信息
    let outBpmDesc = BehaviorRelay(value: "")//心率信息
    var outIsRotating = BehaviorRelay(value: false)//是否旋转封面
    var outNowTime = BehaviorRelay(value: "00:00")
    var outDuration = BehaviorRelay(value: "00:00")
    var outModeImage = BehaviorRelay.init(value: P.image.repeatImage())
    var outCoverImage = BehaviorRelay.init(value: P.image.cover())
    
    
    lazy var outfftData: BehaviorRelay<[[Float]]> = BehaviorRelay.init(value: [])
    let outChartData = BehaviorRelay<[Int]>(value: [])
    var sliderValue = BehaviorRelay<Float>(value: 0.0)
    var progress = BehaviorRelay(value: Float(0.0))
    let isDragging = BehaviorRelay<Bool>(value: false)
    
    var showAudioList: (() -> Void)?
    
    public let playListData = BehaviorRelay<[AudioPlayable]>(value: [])
    public let currentIndex = BehaviorRelay<Int>(value: 0)//播放索引
    
    public var disposeBag = DisposeBag()
    
    init() {}
    
    // 公共方法
    // 子类需要实现此方法
    func stopAndReleaseMemory() {}
    func removeAudioEntity(at index: Int) {}
    func playAudioEntity(_ index: Int, _ playable: AudioPlayable) {}
}

class PlayViewModel: BasePlayViewModel {
    
    // 新增特定输出属性
    let fitData = BehaviorRelay(value: "心率样本: 0个 能量消耗: 0 kcal")
    
    private var player =  AudioPlayer.shared
    private var modeEntity =  Persist.shared.getPlayModeEntity()
    
    override init() {
        super.init()
        
        let audio = Persist.shared.fetchAllAudios()
        
        self.playListData.accept(audio)
        outModeImage.accept(modeEntity.imageName(for: modeEntity.mode))
        
        // 绑定代理事件
        setupProxyBindings()
        
        // 绑定控制事件
        setupControlBindings()
    }
    
    override func stopAndReleaseMemory() {
        // 停止音频播放
        player.stop()
        
        // 移除所有订阅，释放内存
        disposeBag = DisposeBag()
    }
    
    private func setupProxyBindings() {
        let reactivePlayer = player.rx
        
        
        reactivePlayer.state
            .map { $0 == .playing }
            .bind(to: outIsRotating)
            .disposed(by: disposeBag)
    
        
        reactivePlayer.state
            .map { $0 == .finished}
            .subscribe(onNext: { [self] isFinished in
                isFinished ?self.playNewAudioAfterStop():nil
            })
            .disposed(by: disposeBag)
        
        reactivePlayer.fail
            .subscribe(onNext: { error in
                HRToast(message: "\(error.message())", type: .error)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactivePlayer.currentTime,
            isDragging.asObservable()
        )
        .filter { !$0.1 } // 当 isDragging.value == true 的时候，过滤掉 currentTime 事件
        .map { TimeFormat.formatTimeInterval(seconds: $0.0) }
        .bind(to: outNowTime)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactivePlayer.currentTime,
            reactivePlayer.totalTime,
            isDragging.asObservable()
        )
        .filter { !$0.2 } // 当 isDragging.value == true 的时候，过滤掉 进度事件
        .map { Float($0.0 / $0.1) }
        .bind(to: progress)
        .disposed(by: disposeBag)
        
        
        reactivePlayer.totalTime
            .map { TimeFormat.formatTimeInterval(seconds: $0) }
            .bind(to: outDuration)
            .disposed(by: disposeBag)
        
        reactivePlayer.frequencyData
            .bind(to: outfftData)
            .disposed(by: disposeBag)
        
        reactivePlayer.previous.subscribe { _ in
            self.play(action: .previous)
        }
        .disposed(by: disposeBag)
        
        reactivePlayer.next.subscribe { _ in
            self.play(action: .next)
        }
        .disposed(by: disposeBag)
        
        reactivePlayer.outCoverImage
            .map { image -> UIImage in
                return image
            }
            .asObservable()
            .bind(to: outCoverImage)
            .disposed(by: disposeBag)
        
        
        // 读取心率数据更新UI
        reactivePlayer.currentTime
            .subscribe(onNext: { [weak self] currentTimeStamp in
                self?.fetchChartData(currentTimeStamp)
            })
            .disposed(by: disposeBag)
        
    }
    
    func fetchChartData(_ currentTimeStamp: TimeInterval){
        guard playListData.value.count > 0 else { return }
        guard currentIndex.value < playListData.value.count - 1 else { return }
        guard let audioEntity = playListData.value[currentIndex.value] as? AudioEntity else { return }
        let bpms = audioEntity.bpms
        let tolerance: TimeInterval = 0.5
        
        // 查找当前时间对应的索引
        guard let currentIndex = bpms.firstIndex(where: { abs($0.ts - currentTimeStamp) <= tolerance }) else { return }
        
        // 将BPM值添加到outChartData数组中
        var matchedBPMs: [Int] = []
        for i in 0...currentIndex {
            let bpm = bpms[i].bpm
            matchedBPMs.append(bpm)
        }
        outChartData.accept(matchedBPMs)
        
        // 处理其他逻辑
        let bpmDesc = bpms[currentIndex]
        let displayString = "心率:\(bpmDesc.bpm) 次/分 \n消耗: \(bpmDesc.kcal) 千卡"
        outBpmDesc.accept(displayString)
    }
    
    func updateBPMLineChart(){
        if let audioEntity = playListData.value[currentIndex.value] as? AudioEntity {
            let bpmValues: [Int] = audioEntity.bpms.map { $0.bpm }
            outChartData.accept(bpmValues)
            return
        }
        outChartData.accept([])
    }
    
    func setupControlBindings() {
        
        // 播放暂停按钮点击事件
        togglePlay
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                let isPlaying = strongSelf.player.status == .playing
                isPlaying ?strongSelf.player.pause():strongSelf.player.resume()
            })
            .disposed(by: disposeBag)
        
        // 上一首按钮点击事件
        toggleBack.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.play(action: .previous)
        })
        .disposed(by: disposeBag)
        
        // 下一首按钮点击事件
        toggleForward.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.play(action: .next)
        })
        .disposed(by: disposeBag)
        
        // 循环按钮点击事件
        toggleMode
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                let mode = strongSelf.modeEntity.switchNextMode()
                strongSelf.outModeImage.accept(strongSelf.modeEntity.imageName(for: mode))
            })
            .disposed(by: disposeBag)
        
        // 播放列表按钮点击事件
        toggleList
            .subscribe(onNext: { [weak self] in
                self?.showAudioList?()
            })
            .disposed(by: disposeBag)
        
        
        // 播放进度滑块值改变事件
        sliderChanged
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.sliderValue.accept(value)
                let seekToTime = Double(value) * strongSelf.player.duration
                let formattedTime = TimeFormat.formatTimeInterval(seconds: seekToTime)
                strongSelf.fetchChartData(seekToTime)
                strongSelf.outNowTime.accept(formattedTime)
            })
            .disposed(by: disposeBag)
        
        
        Observable.merge(sliderDown, sliderCancel, sliderOutside)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.isDragging.accept(true)
            })
            .disposed(by: disposeBag)
        
        // 播放进度滑块触摸抬起事件
        sliderInside
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.isDragging.accept(false)
                let seekToTime = Double(strongSelf.sliderValue.value) * strongSelf.player.duration
                strongSelf.player.seek(to: seekToTime)
                if strongSelf.player.status != .playing {
                    strongSelf.player.resume()
                }
                print("inside....")
            })
            .disposed(by: disposeBag)
    }
    
    override func removeAudioEntity(at index: Int) {
        if index == currentIndex.value {
            player.stop()
        }
        var currentEntities = playListData.value
        if index < currentEntities.count {
            Persist.shared.deleteAudio(audioEntity: playListData.value[index] as! AudioEntity)
            currentEntities.remove(at: index)
            playListData.accept(currentEntities)
            
            if index == currentIndex.value{
                playAtIndex(0)
            }
        }
    }
    
    func removeCollection(at index: Int) {
        var currentEntities = playListData.value
        if index < currentEntities.count {
            currentEntities.remove(at: index)
            playListData.accept(currentEntities)
            if index == currentIndex.value {
                player.stop()
                if !currentEntities.isEmpty {
                    playAtIndex(0)
                }
            } else if index < currentIndex.value {
                currentIndex.accept(max(0, currentIndex.value - 1))
            }
        }
    }

    //MARK: -播放切换
    override func playAudioEntity(_ index: Int, _ playable: AudioPlayable) {
        // 检查是否需要播放新的音频
        guard index != self.currentIndex.value else {
            return
        }
        playAtIndex(index)
    }
    
    
    func play(action: PlayAction) {
        let at: PlayAction = (modeEntity.mode == .random) ?.random:action
        let newIndex: Int
        switch at {
        case .previous:
            newIndex = max(currentIndex.value - 1, 0)
        case .next:
            newIndex = min(currentIndex.value + 1, playListData.value.count - 1)
        case .random:
            newIndex = Int(arc4random_uniform(UInt32(playListData.value.count)))
        case .current:
            newIndex = currentIndex.value
        }
        playAtIndex(newIndex)
    }
    
    func playNewAudioAfterStop() {
        let currentEntities = playListData.value
        let currentCount = currentEntities.count
        guard currentCount > 0 else { return }
        play(action: .next)
    }
    
    private func playAtIndex(_ newIndex: Int) {
        
        outTitle.accept("")
        progress.accept(0)
        outNowTime.accept("00:00")
        outDuration.accept("00:00")
        outChartData.accept([])
        
        guard playListData.value.count != 0 else { return }
        currentIndex.accept(newIndex)
        let playable = playListData.value[currentIndex.value]
        outTitle.accept(playable.audioName())
        player.play(with: playable)
        updateBPMLineChart()
    }

    //MARK: -数据源切换
    private func switchToAudioSource(_ source: () -> [AudioPlayable]) {
        player.reset()
        let audios = source()
        self.playListData.accept(audios)
        (modeEntity.mode == .random) ?play(action: .random):playAtIndex(0)
    }
    
    func switchToRecordedList() {
        switchToAudioSource(Persist.shared.fetchAllAudios)
    }
    
    func switchToAudioPackageList() {
        switchToAudioSource(Persist.shared.loadAllMusicInfos)
    }
    
    func switchToCollectionList() {
        switchToAudioSource(Persist.shared.fetchAllCollection)
    }
}



