//
//  HeartIconView.swift
//  ScaleLayer
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 YLT. All rights reserved.
//
import Foundation
import UIKit

class HeartIconView: UIImageView {
    
    private var pulsingAnimation: CABasicAnimation?
    
    func startPulsingAnimation(with bpm: Int16) {
        // 计算搏动周期
        let cycleDuration = 60.0 / Double(bpm)
        
        // 设置缩放动画
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = cycleDuration / 2.0
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        
        // 移除之前的动画（如果有）
        layer.removeAnimation(forKey: "pulse")
        
        // 添加新的动画
        layer.add(scaleAnimation, forKey: "pulse")
        pulsingAnimation = scaleAnimation
    }
    
}

