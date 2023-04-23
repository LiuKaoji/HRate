//
//  AudioListViewModel.swift
//  HeartRate
//
//  Created by kaoji on 4/17/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import RxSwift
import RxCocoa
import ESTMusicIndicator

class ViewModel {
    
    private static var totalDuration: String = "00:00"
    public var audioEntity: AudioEntity?
    var currentIndex = 0 // 用于记录当前处理的BPMDescription索引
    
    
    let headerHeight = BehaviorRelay<CGFloat>(value: 100)
    var audioEntities = BehaviorRelay<[AudioEntity]>.init(value: PersistManager.shared.fetchAllAudios())
    let musicPlayer = MusicPlayer()
    var playTime:Observable<String>?
    let bpmStatus:BehaviorRelay<String> = .init(value: "")
    let indicateState:BehaviorRelay<ESTMusicIndicatorViewState>? = .init(value: .paused)
    
    let chartBPMData = BehaviorRelay<[Int]>(value: [])
    let disposeBag = DisposeBag()

    init() {
        
        // 更新时长
        playTime = musicPlayer.rx.currentTime.asObservable().map {
            "\(TimeFormat.formatTimeInterval(seconds: $0))/\(ViewModel.totalDuration)"
        }
        
        // 更新时长
        playTime = musicPlayer.rx.currentTime.asObservable().map {
            "\(TimeFormat.formatTimeInterval(seconds: $0))/\(ViewModel.totalDuration)"
        }
        
        // 更新心率显示文本
//        bpmStatus = ViewModel.calculator.nowBPM.asObservable().map {
//            "当前:\($0) 最大:\(ViewModel.calculator.maxBPM.value) 平均:\(ViewModel.calculator.avgBPM.value)"
//        }
        
        // 读取心率数据更新UI
        musicPlayer.rx.currentTime.subscribe { [weak self] event in
            guard let strongSelf = self, let audioEntity = strongSelf.audioEntity else { return }
            
            // 取整或设置误差范围
            let tolerance: TimeInterval = 0.5
            
            let currentTimeStamp = event.element ?? 0

            // 从当前索引开始，查找符合条件的BPMDescription
            while strongSelf.currentIndex < audioEntity.bpms.count && abs(audioEntity.bpms[strongSelf.currentIndex].ts - currentTimeStamp) <= tolerance {
                // 将BPM值添加到chartBPMData数组中
                strongSelf.chartBPMData.accept(strongSelf.chartBPMData.value + [audioEntity.bpms[strongSelf.currentIndex].bpm])
                // 更新当前处理的索引
                strongSelf.currentIndex += 1
                // 将新的数据添加到计算器
                if  strongSelf.currentIndex < audioEntity.bpms.count - 1{
                    let bpmDesc = audioEntity.bpms[strongSelf.currentIndex]
                    let displayString = "当前:\(bpmDesc.bpm) 最大:\(bpmDesc.max) 平均:\(bpmDesc.max)"
                    strongSelf.bpmStatus.accept(displayString)
                }
            }
        }.disposed(by: disposeBag)
        
        // 转换播放状态至 指示器
        musicPlayer.rx.state.map { musicPlayerState -> ESTMusicIndicatorViewState in
            switch musicPlayerState {
            case .playing:
                return .playing
            case .paused, .stopped:
                return .paused
            case .error:
                return .stopped
            }
        }.do { [weak self] state in
            self?.indicateState?.accept(state)
        }.subscribe()
        .disposed(by: disposeBag)
        
    }
    
    func playMusic(with entity: AudioEntity) {
        
        // 音频模型
        audioEntity = entity
        
        // 音频总时长
        ViewModel.totalDuration = entity.duration
        
        // 音频文件路径
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsDirectory.appendingPathComponent(entity.name!)

        // 还原序列
        currentIndex = 0
        
        // 清空柱状图
        chartBPMData.accept([])
        
        // 启动播放
        musicPlayer.play(url: audioURL)
        
    }
    
    
    func deleteEntity(with entity: AudioEntity){
        
        // 移除元素并更新UI
        audioEntities.accept(audioEntities.value.filter { $0 != entity })
        
        // 从数据库中删除
        PersistManager.shared.deleteAudio(audioEntity: entity)
        
    }
  
}
