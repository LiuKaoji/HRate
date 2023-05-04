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
                .font(.system(size: 17))
                .foregroundColor(.yellow)
                .padding(.top, 0)
                .fixedSize()
            
            PumpZonesView(currentHeartRate: bpmCalculator.nowBPM)
                .padding(.top, 8)
            
            
            GeometryReader { geometry in
                PumpDescriptionView(currentHeartRate: bpmCalculator.nowBPM, geometry: geometry)
            }
            .frame(height: 40)
            .padding(.top, 0)
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
            .padding(.top, 8)
            .padding(.bottom, 0)
        }
        .padding(.horizontal)
    }
}
