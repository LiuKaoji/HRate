//
//  PumpView.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/30/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import SwiftUI


struct PumpView: View {
    @ObservedObject var bpmCalculator: BPMCalculator
    @ObservedObject var timerManager: TimerManager

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(timerManager.timeStr)
                .font(.system(size: 14))
                .foregroundColor(.yellow)
                .padding(.bottom, 8)
            
            HeartRateZonesView(currentHeartRate: bpmCalculator.nowBPM)
                .padding(.bottom, 8)
            
            
            GeometryReader { geometry in
                HeartRateDescriptionView(currentHeartRate: bpmCalculator.nowBPM, geometry: geometry)
            }
            .frame(height: 40)
            .padding(.bottom, 8)
            Spacer(minLength: 0)
            
            HStack {
                HStack {
                    Image("calories")
                        .resizable() // 使图像可调整大小
                        .frame(width: 15, height: 15) // 指定图像的宽度和高度
                    Text("\(Int(bpmCalculator.totalCalories)) 千卡")
                        .font(.system(size: 12))
                }
                
                Spacer()
                
                HStack {
                    Image("average")
                        .resizable() // 使图像可调整大小
                        .frame(width: 15, height: 15) // 指定图像的宽度和高度
                    Text("\(bpmCalculator.avgBPM)次/分")
                        .font(.system(size: 12))
                }
            }
            .padding(.bottom, 8)
            .padding(.top)
        }
        .padding(.horizontal)
    }
}
