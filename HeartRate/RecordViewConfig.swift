//
//  RecordViewConfig.swift
//  HeartRate
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import KDCircularProgress

struct RecordViewConfig {
    // General
    static let backgroundColor = UIColor(named: "BackgroundColor")
    
    // KDCircularProgress
    static let startAngle: CGFloat = -270
    static let progressThickness: CGFloat = 0.6
    static let trackThickness: CGFloat = 0.7
    static let glowMode: KDCircularProgressGlowMode = .noGlow
    static let trackColor = UIColor(named: "BackgroundColorTabBar")
    static let progressColors: [UIColor] = [
        UIColor(named: "ColorCircleThree")!,
        UIColor(named: "ColorCircleTwo")!,
        UIColor(named: "ColorCircleOne")!
    ]
    static let progressSizeDivisor: CGFloat = 1.2
    
    // Screen
    static let bigScreenVerticalCenterDivisor: CGFloat = 1.9
    static let smallScreenVerticalCenterDivisor: CGFloat = 1.5
    
    // BarChartView
    static let axisMinimum: Double = 0.0
    static let axisMaximum: Double = 220.0
    static let noDataTextColor = UIColor.white
    static let noDataText = "佩戴手表再点击检测心率"
    static let labelTextColor = UIColor.white
}
