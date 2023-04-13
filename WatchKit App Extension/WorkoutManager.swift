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
    
    
    // MARK: - Public Methods
    
    /// 开始健身会话的方法。
    /// - Parameter configuration: 健身会话配置。
    func startWorkout(with configuration: HKWorkoutConfiguration) throws {
    
        do {
            
            let workoutSession = try HKWorkoutSession.init(healthStore: healthStore, configuration: configuration)
            workoutSession.startActivity(with: Date())
            currentWorkoutSession = workoutSession
        } catch {
            throw error
        }
    }
    
    /// 停止当前健身会话的方法。
    func stopWorkout() {
        guard let currentWorkoutSession = currentWorkoutSession else { return }
        currentWorkoutSession.end()
        self.currentWorkoutSession = nil
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
    
}
