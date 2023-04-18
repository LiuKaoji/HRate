//
//  BPMTracker.swift
//  HeartRate
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift
import RxCocoa


// 监听心率的状态
enum MonitorState: Equatable {
    case notStarted, launching, running, errorOccur(Error)
    static func == (lhs: MonitorState, rhs: MonitorState) -> Bool {
        switch (lhs, rhs) {
        case (.notStarted, .notStarted),
            (.launching, .launching),
            (.running, .running):
            return true
        case (.errorOccur(let error1), .errorOccur(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}

// 该类用于计算平均心率
class BPMTracker: NSObject {
    
    static let shared = BPMTracker()
    
    public let calculator = BPMCalculator()
    public var state = BehaviorRelay<MonitorState>(value: .notStarted) // 当前心率监测器的状态
    public var dataHandle = PublishSubject<(bpm: Int16, date: String)>() // 心率数据发布对象
    private var bpmAccess: Bool = false // 所有心率值的和
    private var bpms: [Int16] = [] // 所有心率值
    private var messageHandler: WatchConnector.MessageHandler? // Watch App 发送的消息处理对象
    private let healthStore = HKHealthStore() // HealthKit 存储库
    
    override private init() {
        super.init()
        
        // 如果 WatchConnector.shared 不为空，则进行以下操作
        guard let _ = WatchConnector.shared else {
            return
        }
        
        // 创建 Watch App 发送的消息处理对象
        messageHandler = WatchConnector.MessageHandler { [weak self] message in
            guard self?.bpmAccess ?? false else { return }
            self?.handleMessage(message)
        }
        WatchConnector.shared!.addMessageHandler(messageHandler!)
    }
    
    // 开始接收心率数据
    public func startHandle(){
        bpmAccess = true
    }
    
    // 停止接收心率数据
    public func stopHandle(){
        bpmAccess = false
    }
    
    // 处理 Watch App 发送的消息
    private func handleMessage(_ message: [WatchConnector.MessageKey : Any]) {
        // 如果消息包含当前心率值和记录时间，则进行以下操作
        if let currentBPM = message[.heartRateIntergerValue] as? Int16,
           let currentDate = message[.heartRateRecordDate] as? Date {
            let dateStr = TimeFormat.shared.formatter.string(from: currentDate)
            addHeartRate(currentBPM, dateStr) // 添加心率值
            
            state.accept(.running) // 将状态设置为正在运行
        } else if message[.workoutStop] != nil { // 如果消息包含 workoutStop，则将状态设置为未开始
            state.accept(.notStarted)
        } else if message[.workoutStart] != nil { // 如果消息包含 workoutStart，则将状态设置为正在运行
            state.accept(.running)
        } else if let errorData = message[.workoutError] as? Data { // 如果消息包含 workoutError，则将状态设置为出现错误
            if let error = NSKeyedUnarchiver.unarchiveObject(with: errorData) as? Error {
                state.accept(.errorOccur(error))
            }
        }
    }
    
    // 添加心率值并进行统计计算
    func addHeartRate(_ bpm: Int16, _ date: String) {
        calculator.addHeartRate(bpm)
        //抛出数据以存储至数据库
        dataHandle.onNext((bpm, date)) // 发布心率数据
    }
    
    func reset() {
        calculator.reset()
    }
}

extension BPMTracker{
    
    // 启动 Watch App
    func startWatchApp(handler: @escaping (Error?) -> Void) {
        
        WatchConnector.shared?.fetchActivatedSession { _ in
            
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .walking
            configuration.locationType = .outdoor
            
            self.healthStore.startWatchApp(with: configuration) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("healthStore.startWatchApp error:", error)
                        HRToast(message: "手表端无响应,请佩戴并解锁...")
                        handler(error)
                    } else {
                        HRToast(message: "手表端已响应,请耐心等待数据...")
                        handler(nil)
                    }
                    
                }
            }
        }
    }
    
    // 启动状态
    func toggleRunning(completion: @escaping (Error?) -> Void) {
            if state.value != .running {
                startWatchApp { error in
                    if let error = error {
                        self.state.accept(.errorOccur(error))
                    } else {
                        self.state.accept(.running)
                    }
                    completion(error)
                }
            } else {
                state.accept(.notStarted)

                guard let wcManager = WatchConnector.shared else { return }

                wcManager.fetchReachableState { isReachable in
                    if isReachable {
                        wcManager.send([.workoutStop: true])
                    } else {
                        wcManager.transfer([.workoutStop: true])
                    }
                    completion(nil)
                }
            }
        }
}
