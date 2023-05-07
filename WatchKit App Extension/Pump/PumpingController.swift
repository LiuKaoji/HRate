//
//  PumpingController.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/19/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchKit
import HealthKit
import SwiftUI


// 该类 主要展示心率状态
class PumpingController: WKHostingController<PumpView> {
    override var body: PumpView {
        return PumpView(bpmCalculator: bpmCalculator, timerManager: timer)
    }
    private let bpmCalculator = BPMCalculator()// 心率计算器
    private let timer = TimerManager()// 心率计算器
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        handleSubscriptions()
    }
    
    //MARK: - 处理心率数据
    func handleWorkoutSamples(with samples: [HKQuantitySample]){
        let samples: [HKQuantitySample] = samples// 获取您的样本数据
        
        for (index, sample) in samples.enumerated() {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let doubleValue = sample.quantity.doubleValue(for: heartRateUnit)
            let integerValue = Int(round(doubleValue))
            
            self.bpmCalculator.addHeartRate(integerValue) { data in
                do {
                    let encodedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
                    WatchConnector.shared.send([
                        .workoutData : encodedData,
                    ])
                } catch {
                    print("Error encoding WorkoutData:", error)
                }
                
                DispatchQueue.main.async { [self] in
                    guard index == samples.count - 1 else { return }
                    self.bpmCalculator.bpmData.append(integerValue)
                    ////////////self.bpmLabel.setText("\(integerValue)")
                }
            }
        }
    }
    
    // 将处理订阅事件
    func handleSubscriptions() {
        // 处理开始事件
        let _ = NotificationManager.shared.handleSubscription(for: .start, action: .subscribe) { [weak self] _ in
            self?.timer.start()
            WatchConnector.shared.send([.workoutStart: true])
        }
        
        // 处理心率数据
        let _ = NotificationManager.shared.handleSubscription(for: .sample, action: .subscribe) { [weak self] samples in
            if let samples = samples as? [HKQuantitySample] {
                self?.handleWorkoutSamples(with: samples)
            }
        }
        
        //处理结束事件
        let _ = NotificationManager.shared.handleSubscription(for: .stop, action: .subscribe) { [weak self] _ in
            self?.bpmCalculator.reset()
            self?.timer.stop()
            WatchConnector.shared.send([.workoutStop: true])
        }
        
        //处理跳转事件事件
        let _ = NotificationManager.shared.handleSubscription(for: .pageSwitch, action: .subscribe) { [weak self] classCoder in
            if ((classCoder as? PumpingController.Type) != nil) {
                self?.becomeCurrentPage()
            }
        }
        
        //更新用户信息
        let _ = NotificationManager.shared.handleSubscription(for: .userInfo, action: .subscribe) { [weak self] data in
            if let data = data as? Data {
                do {
                    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                    unarchiver.requiresSecureCoding = false
                    NSKeyedUnarchiver.setClass(UserInfo.self, forClassName: "HRate.UserInfo")
                    if let userInfo = try unarchiver.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? UserInfo {
                        UserInfo.save(userInfo)
                        self?.bpmCalculator.updateUserInfo(With: userInfo)
                    }
                } catch {
                    print("解档 WorkoutData 时出错：", error)
                }
            }
        }
    }

}
