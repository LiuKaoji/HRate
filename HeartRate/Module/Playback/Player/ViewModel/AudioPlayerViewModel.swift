//
//  AudioPlayerViewModel.swift
//  HRate
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio
import AVFAudio

class BaseAudioPlayerViewModel {
    // Inputs
    let playPauseTapped = PublishSubject<Void>()
    let previousTapped = PublishSubject<Void>()
    let nextTapped = PublishSubject<Void>()
    let loopTapped = PublishSubject<Void>()
    let playlisTapped = PublishSubject<Void>()
    let sliderTouchDown = PublishSubject<Void>()
    let sliderTouchUpInside = PublishSubject<Void>()
    let sliderTouchCancel = PublishSubject<Void>()
    let sliderTouchOutside = PublishSubject<Void>()
    let sliderValueChanged = PublishSubject<Float>()
    
    // Outputs
    let title = BehaviorRelay(value: "")//播放器标题
    let fileInfo = BehaviorRelay(value: "")//文件信息
    let bpmInfo = BehaviorRelay(value: "")//心率信息
    var isRotating = BehaviorRelay(value: false)//是否旋转封面
    var currentTime = BehaviorRelay(value: "00:00")
    var totalTime = BehaviorRelay(value: "00:00")
    var playPauseImage = BehaviorRelay.init(value: R.image.play()?.withRenderingMode(.alwaysOriginal))
    var modeImage = BehaviorRelay.init(value: R.image.repeatAll()?.withRenderingMode(.alwaysOriginal))
    var coverImage = BehaviorRelay.init(value: R.image.cover()?.withRenderingMode(.alwaysOriginal))
    
    
    lazy var fftData: BehaviorRelay<[[Float]]> = BehaviorRelay.init(value: [])
    let chartBPMData = BehaviorRelay<[Int]>(value: [])
    var sliderValue = BehaviorRelay<Float>(value: 0.0)
    var progress = BehaviorRelay(value: Float(0.0))
    let isDragging = BehaviorRelay<Bool>(value: false)
    
    var showAudioList: (() -> Void)?
    
    public let audioEntities = BehaviorRelay<[AudioPlayable]>(value: [])
    public let currentIndex = BehaviorRelay<Int>(value: 0)
    
    public var disposeBag = DisposeBag()
    
    init() {}
    
    // 公共方法
    // 子类需要实现此方法
    func stopAndReleaseMemory() {}
    func removeAudioEntity(at index: Int) {}
    func playAudioEntity(_ index: Int, _ playable: AudioPlayable) {}
}

class AudioPlayerViewModel: BaseAudioPlayerViewModel {
    
    private let playImage = R.image.play()!.withRenderingMode(.alwaysOriginal)
    private let pauseImage = R.image.pause()!.withRenderingMode(.alwaysOriginal)
    
    // 新增特定输出属性
    let fitData = BehaviorRelay(value: "心率样本: 0个 能量消耗: 0 kcal")
    
    private var player =  AudioPlayer.shared
    private var modeEntity =  PersistManager.shared.getPlayModeEntity()
    
    override init() {
        super.init()
        
        let audio = PersistManager.shared.fetchAllAudios()
        //let audio = AudioLibraryManager.shared.fetchMediaItems()
        self.audioEntities.accept(audio)
        modeImage.accept(modeEntity.imageName(for: modeEntity.mode))
        
        // 绑定事件
        setupProxyBindings()
        
        // 绑定事件
        setupControlBindings()
        
        // 切换到后台播放模式
        DispatchQueue.global().async {
            //AVAudioSession.switchToPlaybackMode()
            DispatchQueue.main.async { [self] in
                //自动播放当前索引
                playCurrentIndex()
            }
        }
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
            .bind(to: isRotating)
            .disposed(by: disposeBag)
        
        reactivePlayer.state
            .map { [self] in $0 == .playing ? pauseImage : playImage }
            .bind(to: playPauseImage)
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
        .bind(to: currentTime)
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
            .bind(to: totalTime)
            .disposed(by: disposeBag)
        
        reactivePlayer.frequencyData
            .bind(to: fftData)
            .disposed(by: disposeBag)
        
        
        reactivePlayer.previous.subscribe { _ in
            self.playPrevious()
        }
        .disposed(by: disposeBag)
        
        reactivePlayer.next.subscribe { _ in
            self.playNext()
        }
        .disposed(by: disposeBag)
        
        reactivePlayer.next.subscribe { _ in
            self.playNext()
        }
        .disposed(by: disposeBag)
        
        reactivePlayer.coverImage
            .map { image -> UIImage in
                return image
            }
            .asObservable()
            .bind(to: coverImage)
            .disposed(by: disposeBag)

        
        // 读取心率数据更新UI
        reactivePlayer.currentTime
            .subscribe(onNext: { [weak self] currentTimeStamp in
                guard let strongSelf = self else { return }
                guard strongSelf.audioEntities.value.count > 0 else { return }
                guard let audioEntity = strongSelf.audioEntities.value[strongSelf.currentIndex.value] as? AudioEntity else { return }
                let bpms = audioEntity.bpms
                let tolerance: TimeInterval = 0.5

                // 查找当前时间对应的索引
                guard let currentIndex = bpms.firstIndex(where: { abs($0.ts - currentTimeStamp) <= tolerance }) else { return }

                // 将BPM值添加到chartBPMData数组中
                var matchedBPMs: [Int] = []
                for i in 0...currentIndex {
                    let bpm = bpms[i].bpm
                    matchedBPMs.append(bpm)
                }
                strongSelf.chartBPMData.accept(matchedBPMs)

                // 处理其他逻辑
                let bpmDesc = bpms[currentIndex]
                //let displayString = "现在:\(bpmDesc.bpm) 最大:\(bpmDesc.max) 平均:\(bpmDesc.avg) (次/分) \n消耗: \(bpmDesc.kcal) (千卡)"
                let displayString = "心率:\(bpmDesc.bpm) 次/分 \n消耗: \(bpmDesc.kcal) 千卡"
                strongSelf.bpmInfo.accept(displayString)
            })
            .disposed(by: disposeBag)

    }
    
    func updateBPMLineChart(){
        if let audioEntity = audioEntities.value[currentIndex.value] as? AudioEntity {
            let bpmValues: [Int] = audioEntity.bpms.map { $0.bpm }
            chartBPMData.accept(bpmValues)
            return
        }
        chartBPMData.accept([])
    }
    
    func setupControlBindings() {
        
        // 播放暂停按钮点击事件
        playPauseTapped
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.player.status == .playing {
                    strongSelf.player.pause()
                } else {
                    strongSelf.player.resume()
                }
            })
            .disposed(by: disposeBag)
        
        // 上一首按钮点击事件
        previousTapped
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.playPrevious()
            })
            .disposed(by: disposeBag)
        
        // 下一首按钮点击事件
        nextTapped
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.playNext()
            })
            .disposed(by: disposeBag)
        
        // 循环按钮点击事件
        loopTapped
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                let mode = strongSelf.modeEntity.switchNextMode()
                strongSelf.modeImage.accept(strongSelf.modeEntity.imageName(for: mode))
            })
            .disposed(by: disposeBag)
        
        // 播放列表按钮点击事件
        playlisTapped
            .subscribe(onNext: { [weak self] in
                self?.showAudioList?()
            })
            .disposed(by: disposeBag)
        
        
        // 播放进度滑块值改变事件
        sliderValueChanged
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.sliderValue.accept(value)
                let seekToTime = Double(value) * strongSelf.player.duration
                let formattedTime = TimeFormat.formatTimeInterval(seconds: seekToTime)
                strongSelf.currentTime.accept(formattedTime)
            })
            .disposed(by: disposeBag)
        
        
        Observable.merge(sliderTouchDown, sliderTouchCancel, sliderTouchOutside)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.isDragging.accept(true)
            })
            .disposed(by: disposeBag)
        
        // 播放进度滑块触摸抬起事件
        sliderTouchUpInside
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
    
    private func playCurrentIndex() {
        guard currentIndex.value < audioEntities.value.count - 1 else { return }
        let playable = audioEntities.value[currentIndex.value]
        title.accept(playable.audioName())
        progress.accept(0)
        currentTime.accept("00:00")
        chartBPMData.accept([])
        player.play(with: playable)
        updateBPMLineChart()
    }
    
    override func removeAudioEntity(at index: Int) {
        var currentEntities = audioEntities.value
        if index < currentEntities.count {
            PersistManager.shared.deleteAudio(audioEntity: audioEntities.value[index] as! AudioEntity)
            currentEntities.remove(at: index)
            audioEntities.accept(currentEntities)
            
            if index == currentIndex.value{
                player.stop()
                currentIndex.accept(0)
                if !currentEntities.isEmpty {
                    playCurrentIndex()
                }
            }
        }
    }
    
    // 点击列表播放指定 内容
    override func playAudioEntity(_ index: Int, _ playable: AudioPlayable) {
        // 检查是否需要播放新的音频
        guard index != self.currentIndex.value else {
            return
        }
        self.currentIndex.accept(index)
        playCurrentIndex()
    }
    
    
    func playNewAudioAfterStop() {
        let currentEntities = audioEntities.value
        let currentCount = currentEntities.count
        guard currentCount > 0 else { return }
        
        switch modeEntity.mode {
        case .single: playCurrentIndex()
        case .all: playNext()
        case .random:  playRamdom()
        }
    }
    
    func playPrevious(){
        guard modeEntity.mode != .random else{ playRamdom(); return}
        let newIndex = max(currentIndex.value - 1, 0)
        currentIndex.accept(newIndex)
        playCurrentIndex()
    }
    
    func playNext(){
        guard modeEntity.mode != .random else{ playRamdom(); return}
        let newIndex = min(currentIndex.value + 1, audioEntities.value.count - 1)
        currentIndex.accept(newIndex)
        playCurrentIndex()
    }
    
    func playRamdom(){
        let newIndex = min(currentIndex.value + 1, audioEntities.value.count - 1)
        currentIndex.accept(newIndex)
        playCurrentIndex()
    }
    
    func switchToRecordedList(){
        player.stop()
        let audios = PersistManager.shared.fetchAllAudios()
        self.audioEntities.accept(audios)
        currentIndex.accept(0)
        playCurrentIndex()
    }
    
    func switchToMediaLibraryList(){
        player.stop()
        let audios = PersistManager.shared.loadAllMusicInfos()
        self.audioEntities.accept(audios)
        currentIndex.accept(0)
        playCurrentIndex()
    }
}



