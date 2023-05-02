//
//  BPMCalculator.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class BPMCalculator: ObservableObject {
    
    @Published public var nowBPM: Int = 0 // 实时心率
    @Published public var minBPM: Int = 0 // 最低心率
    @Published public var maxBPM: Int = 0 // 最高心率
    @Published public var avgBPM: Int = 0 // 平均心率
    @Published public var bpmPercent: Double = 0 // 心率占比 0-220区间
    @Published public var bpmData: [Int] = [] // 所有实时心率 用于计算平均心率及表格显示
    @Published public var totalCalories: Double = 0 //消耗卡路里

    private var userInfo: UserInfo? = UserInfo.loadFromCache()
     var lastHeartRateUpdate: Date?
    
    func addHeartRate(_ bpm: Int, onUpdate: (WorkoutData) -> Void) {
        
        // 全部心率
        var bpms: [Int] = bpmData
        bpms.append(bpm)
        bpmData = bpms
        
        // 心率占比
        bpmPercent = Double(bpm) / 220.0
        
        // 更新最低心率
        minBPM = (bpms.count == 1) ? bpm : bpms.min()!
        
        // 更新最高心率
        maxBPM = (bpms.count == 1) ? bpm : bpms.max()!
        
        // 更新平均心率
        let sum = bpms.reduce(0, +)
        let average = Double(sum) / Double(bpms.count)
        avgBPM = (bpms.count == 1) ? bpm : Int(average)
        
        // 当前心率
        nowBPM = bpm
        
        if let userInfo = userInfo {
            if let lastUpdate = lastHeartRateUpdate {
                let now = Date()
                let timeInterval = now.timeIntervalSince(lastUpdate)
                let caloriesPerMinute = calculateCaloriesPerMinute(bpm: bpm, userInfo: userInfo, timeInterval: timeInterval)
                totalCalories += caloriesPerMinute
            }
            lastHeartRateUpdate = Date() // 更新 lastHeartRateUpdate 的值
        }

        // 回调更新
        onUpdate(WorkoutData(date: Date(), nowBPM: nowBPM, minBPM: minBPM, maxBPM: maxBPM, avgBPM: avgBPM, bpmPercent: bpmPercent, totalCalories: totalCalories, bpmData: bpmData))
    }
    
    func updateUserInfo(With info: UserInfo){
        self.userInfo = info
    }
    
    func calculateCaloriesPerMinute(bpm: Int, userInfo: UserInfo, timeInterval: TimeInterval) -> Double {
        let age = Double(userInfo.age)
        let weight = Double(userInfo.weight)
        let heartRate = Double(bpm)
        let timeInMinutes = timeInterval / 60.0 // 将时间间隔转换为分钟
        
        var caloriesPerMinute = 0.0
        if userInfo.gender == 0 { // 男性
            caloriesPerMinute = ((age * 0.2017) + (weight * 0.1988) + (heartRate * 0.6309) - 55.0969) * timeInMinutes / 4.184
        } else { // 女性
            caloriesPerMinute = ((age * 0.074) + (weight * 0.1263) + (heartRate * 0.4472) - 20.4022) * timeInMinutes / 4.184
        }
        return caloriesPerMinute
    }
    
    func reset() {
        nowBPM = 0
        minBPM = 0
        maxBPM = 0
        avgBPM = 0
        bpmData = []
        totalCalories = 0
        bpmData.removeAll()
    }
}
