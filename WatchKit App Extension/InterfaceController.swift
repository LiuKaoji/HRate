//
//  InterfaceController.swift
//  WatchKitApp Extension
//
//  Created by kaoji on 10/9/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchKit
import HealthKit

class InterfaceController: WKInterfaceController {
    
    @IBOutlet private var startStopButton: WKInterfaceButton!
    
    @IBOutlet private var realTimeHeartRateLabel: WKInterfaceLabel!
    
    @IBOutlet private var imageView: WKInterfaceImage!
    
    private lazy var heartRateChartGenerator: YOLineChartImage = {
        
        let chartGenerator = YOLineChartImage()
        
        chartGenerator.strokeWidth = 1.0
        chartGenerator.strokeColor = .white
        chartGenerator.fillColor = .clear //UIColor.white.withAlphaComponent(0.4)
        chartGenerator.pointColor = .white
        chartGenerator.isSmooth = true
        
        return chartGenerator
    }()
    
    private var defaultWorkoutConfiguration: HKWorkoutConfiguration {
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        configuration.locationType = .outdoor
        
        return configuration
    }
    
    private let workoutManager = WorkoutManager.shared
    
    private var currentQuery: HKAnchoredObjectQuery?
    
    private var messageHandler: WatchConnector.MessageHandler?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        messageHandler = WatchConnector.MessageHandler { [weak self] message in
            if message[.workoutStop] != nil {
                self?.stopWorkout()
            }
        }
        WatchConnector.shared.addMessageHandler(messageHandler!)
    }
    
    deinit {
        messageHandler?.invalidate()
    }
    
    
    // 获取实时心率
    func startWorkout(with configuration: HKWorkoutConfiguration? = nil) {
        
        // 停止workoutsession
        if workoutManager.isWorkoutSessionRunning {
            workoutManager.stopWorkout()
        }
        if currentQuery != nil {
            stopHeartRateQuery()
        }
        
        setTitle("运行中")
        startStopButton.setTitle("停止")
        
        do {
            try workoutManager.startWorkout(with: configuration ?? defaultWorkoutConfiguration)
            
            WatchConnector.shared.send([.workoutStart : true])
            
            startHeartRateQuery()
            
            if WKExtension.shared().applicationState == .active {
                WKInterfaceDevice.current().play(.start)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    WKInterfaceDevice.current().play(.start)
                }
            }
        } catch {
            print("Workout initial error:", error)
            
            let errorData = NSKeyedArchiver.archivedData(withRootObject: error)
            WatchConnector.shared.send([.workoutError : errorData])
        }
    }
    
    func stopWorkout() {
        
        WKInterfaceDevice.current().play(.stop)
        
        setTitle("准备就绪")
        startStopButton.setTitle("开始")
        
        stopHeartRateQuery()
        WatchConnector.shared.send([.workoutStop : true])
        
        workoutManager.stopWorkout()
        
    }
    
    private func startHeartRateQuery() {
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        let query = workoutManager.streamingQuery(withQuantityType: heartRateType, startDate: Date()) { samples in
            self.handle(newHeartRateSamples: samples)
        }
        currentQuery = query
        workoutManager.healthStore.execute(query)
    }
    
    private func stopHeartRateQuery() {
        guard let query = currentQuery else { return }
        workoutManager.healthStore.stop(query)
        currentQuery = nil
    }
    
    private func handle(newHeartRateSamples samples: [HKQuantitySample]) {
        
        let samplesCount = samples.count
        
        for (index, sample) in samples.enumerated() {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            
            let doubleValue = sample.quantity.doubleValue(for: heartRateUnit)
            let integerValue = Int(round(doubleValue))
            let date = sample.startDate
            let dateString = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
            
            print(doubleValue, dateString)
            
            // 通知iPhone程序接收心率数据
            WatchConnector.shared.send([
                .heartRateIntergerValue : integerValue,
                .heartRateRecordDate : date,
                ])
            
            DispatchQueue.main.async {
                
                self.heartRateChartGenerator.values.append(NSNumber(integerLiteral: integerValue))
                
                // 只有一个数据
                guard index == samplesCount - 1 else { return }
                
                // guard WKExtension.shared().applicationState == .active else { return }
                
                self.realTimeHeartRateLabel.setText("\(integerValue)" + " bpm\n" + dateString)
                
                var values = self.heartRateChartGenerator.values
                
                // 需要2个数据才能绘制图
                guard values.count >= 2 else { return }
                
                // 只显示最近的10个心率数据
                let maximumShowsCount = 10
                
                if values.count > maximumShowsCount {
                    values = (values as NSArray).subarray(with: NSMakeRange(values.count - maximumShowsCount, maximumShowsCount)) as! [NSNumber]
                }
                
                self.heartRateChartGenerator.values = values
                
                let imageFrame = CGRect(x: 0, y: 0, width: self.contentFrame.width, height: 50)
                
                let uiImage = self.heartRateChartGenerator.draw(in: imageFrame, scale: WKInterfaceDevice.current().screenScale, edgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) // 绘制图片
                
                self.imageView.setImage(uiImage)
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func startStopButtonDidTap() {
        
        if workoutManager.isWorkoutSessionRunning {
            // 停止监听心率
            stopWorkout()
        }
        else {
            // 开始监听心率
            startWorkout()
        }
    }
    
}
