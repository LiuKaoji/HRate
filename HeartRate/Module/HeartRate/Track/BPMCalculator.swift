//
//  BPMCalculator.swift
//  HeartRate
//
//  Created by kaoji on 4/18/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class BPMCalculator {
    
    public var nowBPM = BehaviorRelay<Int16>(value: 0) // 实时心率
    public var minBPM = BehaviorRelay<Int16>(value: 0) // 最低心率
    public var maxBPM = BehaviorRelay<Int16>(value: 0) // 最高心率
    public var avgBPM = BehaviorRelay<Int16>(value: 0) // 平均心率
    public var bpmPercent = BehaviorRelay<Double>(value: 0) // 心率占比 0-220区间
    public var bpmData = BehaviorRelay<[Int16]>(value: []) // 所有实时心率 用于计算平均心率及表格显示
    
    func addHeartRate(_ bpm: Int16) {
        
        // 全部心率
        var bpms: [Int16] = bpmData.value
        bpms.append(bpm)
        bpmData.accept(bpms)
        
        // 心率占比
        bpmPercent.accept(Double(bpm)/220.0)
        
        // 更新最低心率
        (bpms.count == 1) ?minBPM.accept(bpm):minBPM.accept(bpms.min()!)
        
        // 更新最高心率
        (bpms.count == 1) ?maxBPM.accept(bpm):maxBPM.accept(bpms.max()!)
        
        
        // 更新平均心率
        let sum = bpms.reduce(0, +)
        let average = Double(sum) / Double(bpms.count)
        (bpms.count == 1) ?avgBPM.accept(bpm):avgBPM.accept(Int16(average))
        
        // 当前心率
        nowBPM.accept(bpm)
    }
    
    func reset() {
        nowBPM.accept(0)
        minBPM.accept(0)
        maxBPM.accept(0)
        avgBPM.accept(0)
        bpmData.accept([])
    }
}
