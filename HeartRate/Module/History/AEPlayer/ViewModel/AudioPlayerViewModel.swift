//
//  AudioPlayerViewModel.swift
//  HRate
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio

class AudioPlayerViewModel {
    
    private var bpmIndex: Int = 0
    private let playImage = R.image.play()!.withRenderingMode(.alwaysOriginal)
    private let pauseImage = R.image.pause()!.withRenderingMode(.alwaysOriginal)
    
    // Inputs
    let playPauseButtonTapped = PublishSubject<Void>()
    let previousButtonTapped = PublishSubject<Void>()
    let nextButtonTapped = PublishSubject<Void>()
    let loopButtonTapped = PublishSubject<Void>()
    let playlistButtonTapped = PublishSubject<Void>()
    let sliderTouchDown = PublishSubject<Void>()
    let sliderTouchUp = PublishSubject<Void>()
    let sliderValueChanged = PublishSubject<Float>()
    
    
    // Outputs
    let title = BehaviorRelay(value: "标题")
    let fitData = BehaviorRelay(value: "心率样本: 0个 能量消耗: 0 kcal")
    let fileInfo = BehaviorRelay(value: "文件信息")
    let bpmInfo = BehaviorRelay(value: "当前: 0 最大: 0 平均: 0")
    var isRotating = BehaviorRelay(value: false)
    var currentTime = BehaviorRelay(value: "00:00")
    var totalTime = BehaviorRelay(value: "00:00")
    lazy var playPauseImage: BehaviorRelay<UIImage> = BehaviorRelay.init(value: playImage)
    lazy var fftData: BehaviorRelay<[Float]> = BehaviorRelay.init(value: [])
    let chartBPMData = BehaviorRelay<[Int]>(value: [])
    var sliderValue = BehaviorRelay<Float>(value: 0.0)
    var progress = BehaviorRelay(value: Float(0.0))
    
    private var isDragging = BehaviorRelay(value: false) // 是否正在拖动进度条
    var showAudioList: (() -> Void)? // 导航到下一个页面的闭包
    
    // Private properties
    public let audioEntities = BehaviorRelay<[AudioEntity]>(value: [])
    public let currentIndex = BehaviorRelay<Int>(value: 0)
    private var disposeBag = DisposeBag()
    private var player: AudioPlayer
    
    init(player: AudioPlayer = AudioPlayer.shared) {
        let audios = AudioLibraryManager.shared.fetchMediaItems()
        self.audioEntities.accept(audios)
        self.player = player
        
        // 绑定事件
        setupProxyBindings()
        
        // 绑定事件
        setupControlBindings()
        
        //自动播放当前索引
        playCurrentIndex()
    }
    
    func stopAndReleaseMemory() {
        // 停止音频播放
        player.stop()
        
        // 移除所有订阅，释放内存
        disposeBag = DisposeBag()
    }
    
    private func setupProxyBindings() {
        let reactivePlayer = player.rx
        let isDragging = PublishSubject<Bool>()
        
        reactivePlayer.state
            .map { $0 == .playing }
            .bind(to: isRotating)
            .disposed(by: disposeBag)
        
        reactivePlayer.state
            .map { [self] in $0 == .playing ? pauseImage : playImage }
            .bind(to: playPauseImage)
            .disposed(by: disposeBag)
        
        reactivePlayer.currentTime
            .filter { [weak self] _ in !(self?.isDragging.value ?? false) }
            .map { self.formatTimeInterval(seconds: $0) }
            .bind(to: currentTime)
            .disposed(by: disposeBag)
        
        
        reactivePlayer.totalTime
            .map { self.formatTimeInterval(seconds: $0) }
            .bind(to: totalTime)
            .disposed(by: disposeBag)
        
        reactivePlayer.frequencyData
            .bind(to: fftData)
            .disposed(by: disposeBag)
        
        reactivePlayer.info.map({ info ->String in
            "\(info.sampleRate)"
        })
            .bind(to: fileInfo)
            .disposed(by: disposeBag)
        
        // 读取心率数据更新UI
        reactivePlayer.currentTime
            .subscribe(onNext: { [weak self] currentTimeStamp in
                guard let self = self else { return }
                guard audioEntities.value.count > 0 else{return}
                let bpms = self.audioEntities.value[self.currentIndex.value].bpms
                // 取整或设置误差范围
                let tolerance: TimeInterval = 0.5
                
                // 从当前索引开始，查找符合条件的BPMDescription
                while self.bpmIndex < bpms.count && abs(bpms[self.bpmIndex].ts - currentTimeStamp) <= tolerance {
                    // 将BPM值添加到chartBPMData数组中
                    self.chartBPMData.accept(self.chartBPMData.value + [bpms[self.bpmIndex].bpm])
                    // 更新当前处理的索引
                    self.bpmIndex += 1
                    // 将新的数据添加到计算器
                    if  self.bpmIndex < bpms.count - 1{
                        let bpmDesc = bpms[self.bpmIndex]
                        let displayString = "当前:\(bpmDesc.bpm) 最大:\(bpmDesc.max) 平均:\(bpmDesc.max) 消耗: \(bpmDesc.kcal)kcal"
                        self.bpmInfo.accept(displayString)
                    }
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func setupControlBindings() {
        
        // 播放暂停按钮点击事件
        playPauseButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.player.status == .playing {
                    self.player.pause()
                } else {
                    self.player.resume()
                }
            })
            .disposed(by: disposeBag)
        
        // 上一首按钮点击事件
        previousButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newIndex = max(self.currentIndex.value - 1, 0)
                self.currentIndex.accept(newIndex)
                self.playCurrentIndex()
            })
            .disposed(by: disposeBag)
        
        // 下一首按钮点击事件
        nextButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newIndex = min(self.currentIndex.value + 1, self.audioEntities.value.count - 1)
                self.currentIndex.accept(newIndex)
                self.playCurrentIndex()
            })
            .disposed(by: disposeBag)
        
        // 循环按钮点击事件
        loopButtonTapped
            .subscribe(onNext: { [weak self] in
                HRToast(message: "暂未添加此功能", type: .warning)
            })
            .disposed(by: disposeBag)
        
        // 播放列表按钮点击事件
        playlistButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.showAudioList?()
            })
            .disposed(by: disposeBag)
        
        // 播放进度滑块值改变事件
        sliderValueChanged
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.sliderValue.accept(value)
                let seekToTime = Double(value) * self.player.duration
                let formattedTime = self.formatTimeInterval(seconds: seekToTime)
                self.currentTime.accept(formattedTime)
            })
            .disposed(by: disposeBag)
        
        // 播放进度滑块触摸按下事件
        sliderTouchDown
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isDragging.accept(true)
            })
            .disposed(by: disposeBag)
        
        // 播放进度滑块触摸抬起事件
        sliderTouchUp
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isDragging.accept(false)
                let seekToTime = Double(self.sliderValue.value) * self.player.duration
                self.player.seek(to: seekToTime)
                if self.player.status != .playing {
                    self.player.resume()
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func playCurrentIndex() {
        guard currentIndex.value < audioEntities.value.count - 1 else { return }
        let entity = audioEntities.value[currentIndex.value]
        title.accept(entity.name ?? "标题")
        player.play(with: entity.audioURL())
    }
    
    func removeAudioEntity(at index: Int) {
        var currentEntities = audioEntities.value
        if index < currentEntities.count {
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
    func playAudioEntity(_ audioEntity: AudioEntity) {
        // 检查是否需要播放新的音频
        if let index = audioEntities.value.firstIndex(where: { $0.id == audioEntity.id }) {
            // 如果要播放的音频与当前音频相同且正在播放，则不执行播放操作
            if currentIndex.value == index && player.status == .playing {
                return
            }
            
            currentIndex.accept(index)
            player.play(with: audioEntity.audioURL())
        } else {
            print("音频未找到")
        }
    }
    
    
    private func formatTimeInterval(seconds: TimeInterval) -> String {
        let timeInterval = Int(seconds)
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

