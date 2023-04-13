//
//  HeartRateTracker.swift
//  HeartRate
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import HealthKit

// 监听心率的状态
enum MonitorState {
    case notStarted, launching, running, errorOccur(Error)
}

// 该类用于计算平均心率
class HeartRateTracker: NSObject {
    
    static let shared = HeartRateTracker()
    var state = MonitorState.notStarted //监听状态
    private var bpms: [Int16] = []
    
    private var nowBPM: Int16 = 0 //现在的心率
    private var minBPM: Int16 = 0 //最小心率
    private var maxBPM: Int16 = 0 //最大心率
    private var sumBPM: Int64 = 0 //总心率 所有相加
    private var heartRateCount: Int16 = 0 //心率个数
    private let healthStore = HKHealthStore() // HealthKit 存储库。
    private var messageHandler: WatchConnectivityManager.MessageHandler?//从apple watch发送过来的消息
    typealias TrackerDataHandle = (_ bpm: Int16, _ date: String)->()
    var dataHandle: TrackerDataHandle?
    
    override private init() {
        super.init()
        
        guard let _ = WatchConnectivityManager.shared  else {
            return
        }
        
        messageHandler = WatchConnectivityManager.MessageHandler { [weak self] message in
            guard let `self` = self else { return }
            
            print(message)
            print("\n")
            
            if let newBPM = message[.heartRateIntergerValue] as? Int16,
               let newBPMDate = message[.heartRateRecordDate] as? Date {
                let dateStr = CTZDateFormatter.shared.dateFormatter.string(from: newBPMDate)
                self.addHeartRate(newBPM)// 增加心率数据 进行统计计算
                self.dataHandle?(newBPM, dateStr) // 回调处理

                self.state = .running
            }
            else if message[.workoutStop] != nil{
                self.state = .notStarted
            }
            else if message[.workoutStart] != nil{
                self.state = .running
            }
            else if let errorData = message[.workoutError] as? Data {
                if let error = NSKeyedUnarchiver.unarchiveObject(with: errorData) as? Error {
                    self.state = .errorOccur(error)
                }
            }
        }
        WatchConnectivityManager.shared!.addMessageHandler(messageHandler!)
    }
    
    func addHeartRate(_ bpm: Int16) {
        // 更新最低心率
        if minBPM != 0 {
            minBPM = min(minBPM, bpm)
        } else {
            minBPM = bpm
        }

        // 更新最高心率
        if maxBPM != 0 {
            maxBPM = max(maxBPM, bpm)
        } else {
            maxBPM = bpm
        }
        
        // 所有心率用于显示charts
        nowBPM = bpm
        bpms.append(bpm)

        // 更新平均心率
        sumBPM += Int64(bpm)
        heartRateCount += 1
    }
    
    func getAllBPM() -> [Int16] {
        return bpms
    }
    
    func getNowBPM() -> Int16 {
        return nowBPM
    }

    func getMinBPM() -> Int16 {
        return minBPM
    }

    func getMaxBPM() -> Int16 {
        return maxBPM
    }

    func getAverageBPM() -> Int16 {
        if heartRateCount == 0 {
            return 0
        }
        return Int16(Double(sumBPM) / Double(heartRateCount))
    }

    func reset() {
        nowBPM = 0
        minBPM = 0
        maxBPM = 0
        sumBPM = 0
        heartRateCount = 0
        bpms = []
    }
}

extension HeartRateTracker{
    
    // 启动 Watch App 的方法。
    func startWatchApp(handler: @escaping (Error?) -> Void) {
        
        WatchConnectivityManager.shared?.fetchActivatedSession { _ in
            
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .walking
            configuration.locationType = .outdoor
            
            self.healthStore.startWatchApp(with: configuration) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("healthStore.startWatchApp error:", error)
                    } else {
                        print("healthStore.startWatchApp success.")
                    }
                    handler(error)
                }
            }
        }
    }
}
