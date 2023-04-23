//
//  PumpingController.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/19/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchKit
import HealthKit

// 该类 主要展示心率状态
class PumpingController: WKInterfaceController {
    
    @IBOutlet weak var lineCharImage: WKInterfaceImage!
    @IBOutlet weak var heartImageView: WKInterfaceImage!
    @IBOutlet weak var bpmLabel: WKInterfaceLabel!
    @IBOutlet weak var kcalLabel: WKInterfaceLabel!
    @IBOutlet weak var timerLabel: WKInterfaceTimer!
    private let bpmCalculator = BPMCalculator()// 心率计算器
    var lineChart: SSLineChart?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        generateGraphImage()
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
                    self.bpmLabel.setText("\(integerValue)")
                    self.updateBPMChartData()
                    self.kcalLabel.setText("\(String.init(format: "%.1f", data.totalCalories))千卡")
                }
            }
        }
    }
    
    //MARK: - 处理心率曲线图案
    func generateGraphImage() {
        lineChart = SSLineChart()
        lineChart?.chartMargin = 14
        lineChart?.yLabelFormat = "%1.0f"
        lineChart?.xLabels = (1...5).map{ $0.description }
        lineChart?.yFixedValueMax = 205
        lineChart?.yFixedValueMin = 60
        lineChart?.yLabels = ["60", "135", "205"]
        lineChart?.xLabelWidth = 15.0
        lineChart?.yLabelHeight = 0
        lineChart?.yLabelColor =  UIColor.white
        lineChart?.xLabelColor =  UIColor.white
        
        lineChart?.setGradientColor(colors: [.red, .orange], position: .topDown)
        
        updateBPMChartData()
    }
    
    func updateBPMChartData(){
        
        let data = SSLineChartData()
        data.lineColor = .white
        data.lineAlpha = 1
        data.lineWidth = 0.6
        data.itemCount = bpmCalculator.bpmData.count
        data.getData = { [weak self] index in
            guard let self = self, index <  bpmCalculator.bpmData.count  else { return 0 }
            let yValue = self.bpmCalculator.bpmData[index]
            return CGFloat(yValue)
        }
        
        lineChart?.chartData = [data]
        let img = lineChart?.drawImage()
        lineCharImage.setImage(img)
    }
    
    // 将处理订阅事件
    func handleSubscriptions() {
        // 处理开始事件
        let _ = NotificationManager.shared.handleSubscription(for: .start, action: .subscribe) { [weak self] _ in
            self?.timerLabel.start()
        }
        
        // 处理心率数据
        let _ = NotificationManager.shared.handleSubscription(for: .sample, action: .subscribe) { [weak self] samples in
            if let samples = samples as? [HKQuantitySample] {
                self?.handleWorkoutSamples(with: samples)
            }
        }
        
        //处理结束事件
        let _ = NotificationManager.shared.handleSubscription(for: .stop, action: .subscribe) { [weak self] _ in
            self?.timerLabel.stop()
            self?.bpmCalculator.bpmData.removeAll()
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
                    NSKeyedUnarchiver.setClass(WorkoutData.self, forClassName: "HRate.UserInfo")
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
