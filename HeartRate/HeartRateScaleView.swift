//
//  HeartRateScaleView.swift
//  ScaleLayer
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 YLT. All rights reserved.
//

import Foundation
import UIKit

import UIKit

class HeartRateScaleView: UIView {
    
    private var progressLayer: CAShapeLayer!
    private let minValue: Int16 = 50 // 设置最小刻度值
    private let maxValue: Int16 = 220 // 设置最大刻度值
    private let tickCount = 51 // 设置总刻度数
    private let majorTickCount:Int16 = 11 // 设置主要刻度数量，主要刻度用于显示标签
    
    
    private let lowHeartRate: Int16 = 95//低心率
    private let mediumHeartRate: Int16 = 133//中等心率
    private let highHeartRate: Int16 = 162//高心率

    private let lowBpmColor = UIColor.green.cgColor
    private let midBpmColor = UIColor.yellow.cgColor
    private let highBpmColor = UIColor.red.cgColor
    
    
    // 初始化方法，传入frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        createScale()
    }
    
    // 初始化方法，用于从Interface Builder加载
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createScale()
    }
    
    // 创建刻度尺
    fileprivate func createScale() {
        createCircle() // 创建内层弧线
        createPlate() // 创建刻度
        createPlateLabels() // 创建刻度标签
        createProgressCurve() // 创建进度曲线
        createHeartIconAndLabels()
    }
    
    // 创建内层弧线
    private func createCircle() {
        let circlePath = createArcPath(center: self.center, radius: 100)
        let shapeLayer = createShapeLayer(path: circlePath.cgPath, lineWidth: 10.0, fillColor: UIColor.white.cgColor, strokeColor: UIColor(red: 185/255.0, green: 243/255.0, blue: 110/255.0, alpha: 1.0).cgColor, lineCap: .round)
        self.layer.addSublayer(shapeLayer)
    }
    
    // 创建刻度
    private func createPlate() {
        let perAngle = CGFloat(Double.pi * 5) / 4 / CGFloat(tickCount - 1)
        
        for i in 0..<tickCount {
            let startAngle = -(CGFloat(Double.pi * 9) / 8) + perAngle * CGFloat(i)
            let endAngle = startAngle + perAngle / 5
            
            let bezierPath = createArcPath(center: self.center, radius: 140, startAngle: startAngle, endAngle: endAngle)
            let lineWidth: CGFloat = i % 5 == 0 ? 10.0 : 5.0
            let shapeLayer = createShapeLayer(path: bezierPath.cgPath, lineWidth: lineWidth, fillColor: UIColor.clear.cgColor, strokeColor: UIColor.orange.cgColor)
            
            self.layer.addSublayer(shapeLayer)
        }
    }
    
    // 创建刻度标签
    private func createPlateLabels() {
        let textAngle = Float(Double.pi * 5) / 4 / Float(majorTickCount - 1)
        
        for i in 0..<majorTickCount {
            let angle = -Float(Double.pi) / 8 + textAngle * Float(i)
            let point = computeTextPosition(self.center, angle)
            let value = minValue + (maxValue - minValue) * (majorTickCount - 1 - i) / (majorTickCount - 1)
            
            let label = createLabel(at: point, text: "\(value)", fontSize: 10, textColor: UIColor.gray)
            self.addSubview(label)
        }
    }
    
    // 创建一个方法以在空心处添加心脏图标和标签
    private func createHeartIconAndLabels() {
        // 创建心脏图标
        let heartIcon = UIImage(named: "heart_icon") // 请确保在项目中有名为 "heart_icon" 的图片资源
        let heartImageView = HeartIconView(image: heartIcon)
        heartImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(heartImageView)

        // 创建最小心率标签
        let minBpmLabel = createLabel(text: "MIN: \(minValue)", fontSize: 12, textColor: UIColor.gray)
        minBpmLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(minBpmLabel)

        // 创建最大心率标签
        let maxBpmLabel = createLabel(text: "MAX: \(maxValue)", fontSize: 12, textColor: UIColor.gray)
        maxBpmLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(maxBpmLabel)

        // 创建平均心率标签
        let averageHeartRate = (minValue + maxValue) / 2
        let averageBpmLabel = createLabel(text: "AVG: \(averageHeartRate)", fontSize: 12, textColor: UIColor.gray)
        averageBpmLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(averageBpmLabel)

        // 添加约束
        let views: [String: Any] = ["heartImageView": heartImageView, "minBpmLabel": minBpmLabel, "maxBpmLabel": maxBpmLabel, "averageBpmLabel": averageBpmLabel]

        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[heartImageView]-[minBpmLabel]", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(horizontalConstraints)

        NSLayoutConstraint.activate([
            heartImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -40),
            heartImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
            heartImageView.widthAnchor.constraint(equalToConstant: 60),
            heartImageView.heightAnchor.constraint(equalToConstant: 60),
            
            minBpmLabel.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor, constant: -20),
            maxBpmLabel.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor),
            averageBpmLabel.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor, constant: 20),
            
            minBpmLabel.leadingAnchor.constraint(equalTo: heartImageView.trailingAnchor),
            maxBpmLabel.leadingAnchor.constraint(equalTo: heartImageView.trailingAnchor),
            averageBpmLabel.leadingAnchor.constraint(equalTo: heartImageView.trailingAnchor)
        ])

    }
    
    private func createProgressCurve() {
        let bezierPath = createArcPath(center: self.center, radius: 120)
        progressLayer = createShapeLayer(path: bezierPath.cgPath, lineWidth: 30.0, fillColor: UIColor.clear.cgColor, strokeColor: UIColor.clear.cgColor)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [lowBpmColor, midBpmColor, highBpmColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.mask = progressLayer
        self.layer.addSublayer(gradientLayer)
        
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0.8
    }

    
    private func createArcPath(center: CGPoint, radius: CGFloat, startAngle: CGFloat = -(CGFloat(Double.pi * 9) / 8), endAngle: CGFloat = CGFloat(Double.pi) / 8) -> UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    private func createShapeLayer(path: CGPath, lineWidth: CGFloat, fillColor: CGColor, strokeColor: CGColor, lineCap: CAShapeLayerLineCap? = nil) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = fillColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.path = path
        if let lineCap = lineCap {
            shapeLayer.lineCap = lineCap
        }
        return shapeLayer
    }
    
    private func computeTextPosition(_ arcCenter: CGPoint, _ angle: Float) -> CGPoint {
        let x = 155 * cosf(angle)
        let y = 155 * sinf(angle)
        let position: CGPoint = CGPoint(x: arcCenter.x + CGFloat(x), y: arcCenter.y - CGFloat(y))
        return position
    }
    
    private func createLabel(at point: CGPoint = .zero, text: String, fontSize: CGFloat, textColor: UIColor, width: CGFloat = 23) -> UILabel {
        let label = UILabel(frame: CGRect(x: point.x - 8, y: point.y - 7, width: width, height: 14))
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }
    
    func updateProgress(_ bpm: Int16) {
        // 将BPM限制在最小值和最大值之间
        let clampedBPM = min(max(minValue, Int16(Int(bpm))), maxValue)
        
        // 计算BPM所对应的进度
        let progress = CGFloat(clampedBPM - minValue) / CGFloat(maxValue - minValue)
            
        progressLayer.strokeEnd = progress
        updateGradientColor(bpm)
        
        // 更新心脏图标的动画
        if let heartIconView = self.subviews.first(where: { $0 is HeartIconView }) as? HeartIconView {
            heartIconView.startPulsingAnimation(with: clampedBPM)
        }
    }
    
    private func updateGradientColor(_ bpm: Int16) {
        let heartRate: Int16 = bpm
        
        if heartRate < lowHeartRate {
            progressLayer.strokeColor = lowBpmColor
        } else if heartRate >= lowHeartRate && heartRate < mediumHeartRate {
            let percentage = CGFloat(heartRate - lowHeartRate) / CGFloat(mediumHeartRate - lowHeartRate)
            progressLayer.strokeColor = UIColor(red: 1.0 - percentage, green: 1.0, blue: 0.0, alpha: 1.0).cgColor
        } else if heartRate >= mediumHeartRate && heartRate < highHeartRate {
            let percentage = CGFloat(heartRate - mediumHeartRate) / CGFloat(highHeartRate - mediumHeartRate)
            progressLayer.strokeColor = UIColor(red: 1.0 - percentage, green: 1.0, blue: 0.0, alpha: 1.0).cgColor
        } else {
            progressLayer.strokeColor = highBpmColor
        }
    }
}
