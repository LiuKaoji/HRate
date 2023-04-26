//
//  BPMTracker.swift
//  HRate
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
    public var workoutData = BehaviorRelay<WorkoutData?>(value: nil)
    public var state = BehaviorRelay<MonitorState>(value: .notStarted) // 当前心率监测器的状态
    private var bpmAccess: Bool = false // 所有心率值的和
    private var bpms: [Int] = [] // 所有心率值
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
    private func handleMessage(_ message: [WatchConnector.MessageKey: Any]) {
        
        if let transferData = message[.workoutData] as? Data {
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: transferData)
                unarchiver.requiresSecureCoding = false
                NSKeyedUnarchiver.setClass(WorkoutData.self, forClassName: "WatchKit_App_Extension.WorkoutData")
                if let workData = try unarchiver.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? WorkoutData {
                    self.workoutData.accept(workData)
                }
            } catch {
                print("解档 WorkoutData 时出错：", error)
            }
        } else if message[.workoutStop] != nil { // 如果消息包含 workoutStop，则将状态设置为未开始
            state.accept(.notStarted)
        } else if message[.workoutStart] != nil { // 如果消息包含 workoutStart，则将状态设置为正在运行
            state.accept(.running)
        } else if let errorData = message[.workoutError] as? Data { // 如果消息包含 workoutError，则将状态设置为出现错误
            
            do {
                if let error = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSError.self, from: errorData) {
                    state.accept(.errorOccur(error))
                }
            } catch {
                print("解档错误时出错：", error)
            }
        }
    }
}

extension BPMTracker{
    
    // 启动 Watch App
    func startWatchApp(handler: @escaping (Error?) -> Void) {
        
        WatchConnector.shared?.fetchActivatedSession { _ in
            
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .cycling
            configuration.locationType = .indoor
            
            self.healthStore.startWatchApp(with: configuration) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("healthStore.startWatchApp error:", error)
                        HRToast(message: error.localizedDescription, type: .error)
                        handler(error)
                    } else {
                        HRToast(message: "手表端已响应,请耐心等待数据...", type: .success)
                        handler(nil)
                    }
                    
                }
            }
        }error: {
            HRToast(message: "无法与Apple Watch建立通讯...", type: .error)
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
