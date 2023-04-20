//
//  InterfaceController.swift
//  WatchKitApp Extension
//
//  Created by kaoji on 10/9/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchKit
import HealthKit

let sampleNotificationName = Notification.Name("SampleNotification")

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var actionImage: WKInterfaceImage!
    
    // 默认训练配置
    private var defaultWorkoutConfiguration: HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .cycling
        configuration.locationType = .indoor
        return configuration
    }
    
    private let workoutManager = WorkoutManager.shared
    private var currentQuery: HKAnchoredObjectQuery?
    private var messageHandler: WatchConnector.MessageHandler?
  

    
    // 界面处理
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // 模拟启动
        let _ = NotificationManager.shared.subscribeToActionNotification(using: { [weak self] in
            self?.startworkoutAction()
        })

        messageHandler = WatchConnector.MessageHandler { [weak self] message in
            if message[.workoutStop] != nil {
                self?.stopWorkout()
            }
        }
        WatchConnector.shared.addMessageHandler(messageHandler!)
    }
    
    // Deinit
    deinit {
        messageHandler?.invalidate()
    }

    
    // 停止训练
    func stopWorkout() {
        WKInterfaceDevice.current().play(.stop)
        stopHeartRateQuery()
        WatchConnector.shared.send([.workoutStop : true])
        workoutManager.stopWorkout()
        self.actionImage.setImageNamed("start")
        NotificationManager.shared.postStopNotification()
        self.becomeCurrentPage()
    }
    
    // 开始读取心率
    private func startHeartRateQuery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = workoutManager.streamingQuery(withQuantityType: heartRateType, startDate: Date()) { samples in
            self.handle(newHeartRateSamples: samples)
        }
        currentQuery = query
        workoutManager.healthStore.execute(query)
    }
    
    // 停止读取心率
    private func stopHeartRateQuery() {
        guard let query = currentQuery else { return }
        workoutManager.healthStore.stop(query)
        currentQuery = nil
    }
    
    // 接收新的心率
    private func handle(newHeartRateSamples samples: [HKQuantitySample]) {
        NotificationManager.shared.postSampleNotification(with: samples)
    }

    
    // 点击开始/停止
    @IBAction func onClickAction() {
        
        if workoutManager.isWorkoutSessionRunning {
            // 停止监听心率
            stopWorkout()
        } else {
            // 开始监听心率
            startworkoutAction()
        }

    }
    
    func startworkoutAction(){
        // 开始监听心率
        startWorkout { isStarted in
            self.actionImage.setImageNamed("stop")
            NotificationManager.shared.postStartNotification()
            NotificationManager.shared.postPageSwitchNotification(classType: PumpingController.classForCoder())
        }
    }
    
    func startWorkout(with configuration: HKWorkoutConfiguration? = nil, statusUpdate: @escaping (_ isStarted: Bool) -> Void = { _ in }) {
        if workoutManager.isWorkoutSessionRunning {
            workoutManager.stopWorkout()
        }
        if currentQuery != nil {
            stopHeartRateQuery()
        }

        // 使用闭包回调更新UI
        statusUpdate(true)

//        do {
//            try workoutManager.startWorkout(with: configuration ?? defaultWorkoutConfiguration)
//
//        } catch {
//            print("Workout initial error:", error)
//            let errorData = NSKeyedArchiver.archivedData(withRootObject: error)
//            WatchConnector.shared.send([.workoutError : errorData])
//        }
        
        workoutManager.startWorkoutAndFetchHeartRate(with: configuration ?? defaultWorkoutConfiguration) { samples, error in
            if let error = error{
                print("Workout initial error:", error as Any)
                let errorData = NSKeyedArchiver.archivedData(withRootObject: error)
                WatchConnector.shared.send([.workoutError : errorData])
            }else{
                WatchConnector.shared.send([.workoutStart : true])
                self.startHeartRateQuery()
                   
                if WKExtension.shared().applicationState == .active {
                    WKInterfaceDevice.current().play(.start)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        WKInterfaceDevice.current().play(.start)
                    }
                }
                
                if let samples = samples {
                    self.handle(newHeartRateSamples: samples)
                }
            }
        }
        
    }

}
