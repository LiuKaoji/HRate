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
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    private let bpmCalculator = BPMCalculator()// 心率计算器
   
    var lineChart: SSLineChart?
    private var heartRate: Double = 0 {
        didSet {
           
        }
    }
    
    private lazy var timer: OSTimer = OSTimer.init { seconds in
        // 文本显示
        self.timeLabel.setText("    训练时长: \(TimeFormat.formatTimeInterval(seconds: TimeInterval(seconds)))")
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        generateGraphImage()
        
        //处理开始事件
        let _ = NotificationManager.shared.subscribeToStartNotification { [weak self] in
            self?.timer.start()
        }
        
        // 处理心率数据
        let _ = NotificationManager.shared.subscribeToSampleNotification(using: { [weak self] samples in
            self?.handleWorkoutSamples(with: samples)
        })
        
        //处理结束事件
        let _ = NotificationManager.shared.subscribeToStopNotification(using: { [weak self] in
            self?.timer.stop()
            self?.timer.reset()
            self?.timeLabel.setText("    训练时长: 00:00")
            self?.bpmLabel.setText("---")
            self?.bpmCalculator.bpmData.removeAll()
            self?.updateBPMChartData()
            self?.heartImageView.setImage(.init(named: "heart"))
        })
        
        //处理跳转事件事件
        let _ = NotificationManager.shared.subscribeToPageSwitchNotification(forClass: self.classForCoder) { _ in
            self.becomeCurrentPage()
        }
    }
    
    func handleWorkoutSamples(with samples: [HKQuantitySample]){
        let samples: [HKQuantitySample] = samples// 获取您的样本数据
        
        for (index, sample) in samples.enumerated() {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let doubleValue = sample.quantity.doubleValue(for: heartRateUnit)
            let integerValue = Int(round(doubleValue))
            // 发送心率至iPhone
//            WatchConnector.shared.send([
//                .bpmValue : integerValue,
//                .bpmDate : date,
//            ])
            
            self.bpmCalculator.addHeartRate(integerValue) { data in
                do {
                    let encodedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
                    WatchConnector.shared.send([
                        .workoutData : encodedData,
                    ])
                } catch {
                    print("Error encoding WorkoutData:", error)
                }
                
            }
            
            DispatchQueue.main.async { [self] in
                guard index == samples.count - 1 else { return }
                self.bpmCalculator.bpmData.append(integerValue)
                self.bpmLabel.setText("\(integerValue)")
                self.updateBPMChartData()
                //self.bpmTimedController.updateBPM(Double(integerValue))
            }
        }
    }
    
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
}
