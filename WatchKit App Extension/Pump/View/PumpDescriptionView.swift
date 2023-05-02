//
//  PumpDescriptionView.swift
//  WatchKit App Extension
//
//  Created by kaoji on 5/2/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct PumpDescriptionView: View {
    let currentHeartRate: Int
    let geometry: GeometryProxy
    @State private var isTextVisible: Bool = false
    let zoneColors: [Color] = Array([.green, .yellow, .orange, .red, .purple])
    let zoneThresholds: [Int] = [60, 100, 120, 160, 190, 220]
    private var currentZoneIndex: Int {
        for (index, threshold) in zoneThresholds.enumerated() {
            if currentHeartRate < threshold {
                return max(index - 1, 0)
            }
        }
        return zoneThresholds.count - 2
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                Text("\(currentHeartRate)")
                    .font(.system(size: 20))
                    .foregroundColor(zoneColors[currentZoneIndex])
                Text("次/分")
                    .font(.system(size: 20))
                    .foregroundColor(zoneColors[currentZoneIndex])
            }
            
            HStack {
                Image(systemName: "eye")
                    .resizable()
                    .frame(width: 10, height: 7)
                    .padding(.leading, 5)
                
                Text(isTextVisible ? userInfoText() : "点击查看")
                    .font(.system(size: 10))
            }
            .onTapGesture {
                isTextVisible.toggle()
                if isTextVisible {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isTextVisible = false
                    }
                }
            }
        }
        .frame(width: geometry.size.width, alignment: .center)
    }
    
    private func userInfoText() -> String {
        let userInfo = UserInfo.loadFromCache()!
        let genderText = userInfo.gender == 0 ? "G" : "M"
        let ageText = userInfo.age
        let heightText = userInfo.height
        let weightText = userInfo.weight
        return "\(genderText)/\(ageText)/\(heightText)/\(weightText)"
    }
}
