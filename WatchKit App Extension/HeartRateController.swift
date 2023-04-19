//
//  HeartRateController.swift
//  InstantHeart
//
//  Created by kaoji on 3/27/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import HealthKit

struct HeartRate: Equatable {
    
    // 每分钟平均心率
    let bpm: Int
    
    // 每次记录心跳的时间
    let date: Date
    
    // 判断两个HeartRate是否相等
    static func ==(lhs: HeartRate, rhs: HeartRate) -> Bool {
        return lhs.bpm == rhs.bpm && lhs.date == rhs.date
    }
}

class HeartRateController {
    
    // 单例模式，全局访问
    static let sharedInstance = HeartRateController()
    
    private init() {}
    
    private let healthStore = HKHealthStore()
    
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    
    private let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
    
    /// 获取指定时间范围内的心率数据
    /// - Parameters:
    ///   - startDate: 开始时间，默认为nil
    ///   - endDate: 结束时间，默认为nil
    ///   - limit: 返回的数据条数限制，默认为不限制
    ///   - handler: 回调闭包，返回一组按时间降序排列的HeartRate对象
    func fetchHeartRates(startDate: Date? = nil, endDate: Date? = nil, limit: Int = HKObjectQueryNoLimit, handler: @escaping ([HeartRate], Error?) -> Void) {
        
        fetchHeartRateSamplesWithStartDate(startDate, endDate: endDate, limit: limit) { samples, error in
            let heartRates = self.heartRatesWithSamples(samples)
            handler(heartRates, error)
            
            if let error = error {
                print("fetchHeartRates error: \(error)")
            }
        }
    }
    
    /// 获取指定时间范围内的心率样本
    /// - Parameters:
    ///   - startDate: 开始时间
    ///   - endDate: 结束时间
    ///   - limit: 返回的数据条数限制
    ///   - handler: 回调闭包，返回一组按时间降序排列的HKQuantitySample对象
    private func fetchHeartRateSamplesWithStartDate(_ startDate: Date?, endDate: Date?, limit: Int, handler: @escaping ([HKQuantitySample], Error?) -> Void) {
        
        requestAuthorization {
            
            let adjustedEndDate = endDate?.addingTimeInterval(-1) // complication requires the samples must be before the end date.
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: adjustedEndDate, options: [.strictEndDate])
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: self.heartRateType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { query, samples, error in
                
                if let samples = samples as? [HKQuantitySample] {
                    handler(samples, error)
                } else {
                    handler([], error)
                }
            }
            
            self.healthStore.execute(query)
        }
    }
    
    /// 将HKQuantitySample对象转换为HeartRate对象
    /// - Parameter samples: 一组HKQuantitySample对象
    /// - Returns: 转换后的HeartRate对象数组
    private func heartRatesWithSamples(_ samples: [HKQuantitySample])-> [HeartRate] {
        
        var heartRates = [HeartRate]()
        
        for sample in samples {
            let bpm = Int(round(sample.quantity.doubleValue(for: heartRateUnit)))
            let date = sample.endDate
            heartRates.append(HeartRate(bpm: bpm, date: date))
        }
        
        return heartRates
    }
    
    /// 请求授权访问HealthKit数据
    /// - Parameter handler: 授权成功后执行的闭包
    private func requestAuthorization(_ handler: @escaping () -> Void) {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes = Set([heartRateType])
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            handler()
            if let error = error {
                print(error)
            }
        }
    }
    
    /// 生成随机心率数据
    /// - Parameter endDate: 随机数据的结束时间
    /// - Returns: 生成的随机HeartRate对象数组
    private func randomHeartRatesWithEndDate(_ endDate: Date) -> [HeartRate] {
        
        var heartRates = [HeartRate]()
        
        for i in (0 ..< 500).reversed() {
            let date = endDate.addingTimeInterval(-10 * 60 * TimeInterval(i) - 60)
            
            let heartRate = HeartRate(bpm: 60 + Int(arc4random_uniform(100)), date: date)
            heartRates.append(heartRate)
        }
        
        return heartRates
    }
    
    /// 保存随机心率数据到HealthKit
    /// - Parameters:
    ///   - endDate: 随机数据的结束时间
    ///   - amount: 生成随机数据的数量，默认为6 * 24 * 5条
    func saveRandomHeartRatesWithEndDate(_ endDate: Date, amount: Int = 6 * 24 * 5) {
        
        requestAuthorization {
            
            var heartRateSamples = [HKQuantitySample]()
            
            for i in 0 ..< amount {
                let date = endDate.addingTimeInterval(-10 * 60 * TimeInterval(i) - 60)
                let randomBPM = 60 + Double(arc4random_uniform(101))
                let sample = HKQuantitySample(type: self.heartRateType, quantity: HKQuantity(unit: self.heartRateUnit, doubleValue: randomBPM), start: date, end: date, device: HKDevice.local(), metadata: nil)
                
                heartRateSamples.append(sample)
            }
            
            self.healthStore.save(heartRateSamples) { success, error in
                print("save objects success? \(success), error \(error?.localizedDescription)")
            }
        }
    }
}

