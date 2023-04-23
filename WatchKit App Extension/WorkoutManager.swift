//
//  WorkoutManager.swift
//  HeartRate
//
//  Created by kaoji on 01/25/23.
//  Copyright © 2023 kaoji. All rights reserved.
//
import Foundation
import HealthKit


class WorkoutManager {
    
    // MARK: - Initial
    private var heartRateUpdateTimer: Timer?

    
    /// 共享单例。
    static let shared = WorkoutManager()
    
    private init() {}
    
    
    // MARK: - Properties
    
    let healthStore = HKHealthStore()
    
    // 表示当前健身会话是否正在运行的布尔值属性。
    var isWorkoutSessionRunning: Bool {
        return currentWorkoutSession != nil
    }
    
    // 当前健身会话的私有存储属性。
    private(set) var currentWorkoutSession: HKWorkoutSession?
    
    // 一次锻炼记录
    private(set) var currentWorkout: HKWorkout?

    // 心率类型和单位
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    
    // MARK: - Public Methods
    
    /// 开始健身会话的方法。
    /// - Parameter configuration: 健身会话配置。
    func startWorkout(with configuration: HKWorkoutConfiguration) throws {
        
        do {
            
            let workoutSession = try HKWorkoutSession.init(healthStore: healthStore, configuration: configuration)
            workoutSession.startActivity(with: Date())
            currentWorkoutSession = workoutSession
            
            
            // 创建 HKWorkout 对象并保存
            let workout = HKWorkout(activityType: configuration.activityType, start: Date(), end: Date().addingTimeInterval(24 * 60 * 60))
            healthStore.save(workout) { success, error in
                if let error = error {
                    print("Error saving workout: \(error.localizedDescription)")
                } else {
                    print("Workout saved successfully")
                    self.currentWorkout = workout
                }
            }
            
        } catch {
            throw error
        }
    }
    
    
    /// 开始健身会话的方法 并立即获取到最近心跳。
    /// - Parameter configuration: 健身会话配置。
    typealias HeartRateHandler = ([HKQuantitySample]?, Error?) -> Void
    func startWorkoutAndFetchHeartRate(with configuration: HKWorkoutConfiguration, heartRateHandler: @escaping HeartRateHandler) {
        do {
            try startWorkout(with: configuration)
            
            // 立即获取当前心率
            fetchMostRecentHeartRate { (sample, error) in
                guard let sample = sample else {
                    print("获取最近的心率失败：", error ?? "未知错误")
                    heartRateHandler(nil, error)
                    return
                }
                heartRateHandler([sample], nil)
            }
        } catch {
            print("启动健身会话失败：", error)
            heartRateHandler(nil, error)
        }
    }
    
    /// 停止当前健身会话的方法。
    func stopWorkout() {
        guard let currentWorkoutSession = currentWorkoutSession else { return }
        currentWorkoutSession.end()
        self.currentWorkoutSession = nil
        
        // 结束 HKWorkout 对象并保存
        if let workout = currentWorkout {
            let endDate = Date()
            
            let updatedMetadata = workout.metadata?.merging([HKMetadataKeySyncVersion: workout.uuid.uuidString]) { _, new in new }
            let updatedWorkout = HKWorkout(activityType: workout.workoutActivityType,
                                           start: workout.startDate,
                                           end: endDate,
                                           workoutEvents: workout.workoutEvents,
                                           totalEnergyBurned: workout.totalEnergyBurned,
                                           totalDistance: workout.totalDistance,
                                           device: workout.device,
                                           metadata: updatedMetadata)
            
            healthStore.save(updatedWorkout) { success, error in
                if let error = error {
                    print("Error saving finished workout: \(error.localizedDescription)")
                } else {
                    print("Finished workout saved successfully")
                    self.currentWorkout = nil
                }
            }
        }
    }
    
    /// 创建并返回一个可用于流式传输指定类型健身数据的 HKAnchoredObjectQuery 对象。
    /// - Parameters:
    ///   - type: 要查询的健身数据类型。
    ///   - startDate: 查询开始时间。
    ///   - samplesHandler: 处理样本数据的闭包。
    /// - Returns: 配置好的HKAnchoredObjectQuery对象。
    func streamingQuery(withQuantityType type: HKQuantityType, startDate: Date, samplesHandler: @escaping ([HKQuantitySample]) -> Void) -> HKAnchoredObjectQuery {
        
        // 设置一个谓词，以仅获取从`startDate`开始的本地设备样本。
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
        
        let queryUpdateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { _, samples, _, _, error in
            
            if let error = error {
                print("查询心率异常\(type)：\(error)")
            }
            
            if let samples = samples as? [HKQuantitySample], samples.count > 0 {
                DispatchQueue.main.async {
                    samplesHandler(samples)
                }
            }
        }
        
        let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit), resultsHandler: queryUpdateHandler)
        query.updateHandler = queryUpdateHandler
        
        return query
    }
    
    func fetchMostRecentHeartRate(completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (_, results, error) in
            DispatchQueue.main.async {
                completion(results?.first as? HKQuantitySample, error)
            }
        }
        
        healthStore.execute(query)
    }
    
    // 保存心率
    func saveHeartRateSample(_ heartRate: Int, at date: Date, completion: @escaping (Bool, Error?) -> Void) {
        requestAuthorization {
            let heartRateSample = HKQuantitySample(type: self.heartRateType, quantity: HKQuantity(unit: self.heartRateUnit, doubleValue: Double(heartRate)), start: date, end: date)
            self.healthStore.save(heartRateSample) { success, error in
                completion(success, error)
            }
        }
    }

    // 保存消耗卡路里
    func saveCalorieSample(_ calories: Double, startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        requestAuthorization {
            let energyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let energyBurnedQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories)
            let energyBurnedSample = HKQuantitySample(type: energyBurnedType, quantity: energyBurnedQuantity, start: startDate, end: endDate)

            self.healthStore.save(energyBurnedSample) { success, error in
                completion(success, error)
            }
        }
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
}
