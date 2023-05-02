//
//  PumpZonesView.swift
//  WatchKit App Extension
//
//  Created by kaoji on 5/2/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct RoundedCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



struct PumpZonesView: View {
    let currentHeartRate: Int
    let zoneColors: [Color] = AppConfig.zoneColors
    let zoneThresholds: [Int] = AppConfig.zoneThresholds
    let zoneDescriptions: [String] = AppConfig.zoneDescriptions
    
    private var currentZoneIndex: Int {
        for (index, threshold) in zoneThresholds.enumerated() {
            if currentHeartRate < threshold {
                return max(index - 1, 0)
            }
        }
        return zoneThresholds.count - 2
    }

    var body: some View {
        VStack {
            zonesBarWithScale
                .padding(.bottom, 8)
       
            alignedTexts(items: zoneDescriptions, font: .system(size: 10, weight: .bold), color: .gray, currentItem: zoneDescriptions[currentZoneIndex], currentItemColor: zoneColors[currentZoneIndex])
                .padding(.bottom, 8)
        }
    }
    
    private var zonesBarWithScale: some View {
        GeometryReader { geometry in
            let zoneWidth = geometry.size.width / CGFloat(zoneThresholds.count - 1)
            HStack(spacing: 0) {
                ForEach(0..<zoneThresholds.count - 1) { index in
                    ZoneStack(zoneIndex: index, zoneWidth: zoneWidth, geometry: geometry, currentHeartRate: currentHeartRate, zoneColors: zoneColors, zoneThresholds: zoneThresholds)
                }
            }
            .overlay(alignedThresholdTexts(items: zoneThresholds, font: .system(size: 6, weight: .bold), color: .white, zoneWidth: zoneWidth, zoneHeight: geometry.size.height * 0.9))
        }
        .frame(height: 10)
    }

    private func alignedTexts<T: Hashable>(items: [T], font: Font, color: Color, currentItem: T? = nil, currentItemColor: Color? = nil) -> some View {
        AppUtils.alignedTexts(items: items, font: font, color: color, currentItem: currentItem, currentItemColor: currentItemColor)
    }
    
    private func alignedThresholdTexts<T: Hashable>(items: [T], font: Font, color: Color, zoneWidth: CGFloat, zoneHeight: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                if index < items.count {
                    VStack(alignment: .trailing) {
                        Text(String(describing: items[index]))
                            .font(font)
                            .foregroundColor(color)
                            .padding(.bottom, 6)
                        Spacer()
                    }
                    .frame(width: zoneWidth, height: zoneHeight * 0.8)
                }
            }
        }
    }
}

struct ZoneStack: View {
    let zoneIndex: Int
    let zoneWidth: CGFloat
    let geometry: GeometryProxy
    let currentHeartRate: Int
    let zoneColors: [Color]
    let zoneThresholds: [Int]

    var body: some View {
        let isInCurrentZone = currentHeartRate >= zoneThresholds[zoneIndex] && currentHeartRate < zoneThresholds[zoneIndex + 1]
        let zoneHeight = isInCurrentZone ? geometry.size.height : geometry.size.height * 0.9
        let cornerRadius: CGFloat = 6
        let corners: UIRectCorner = zoneIndex == 0 ? [.topLeft, .bottomLeft] : (zoneIndex == zoneThresholds.count - 2 ? [.topRight, .bottomRight] : [])

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(LinearGradient(gradient: Gradient(colors: [zoneColors[zoneIndex], zoneColors[zoneIndex].opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                .frame(width: zoneWidth, height: zoneHeight)
                .mask(RoundedCorners(corners: corners, radius: cornerRadius))

            VStack {
                ForEach(1..<5) { subIndex in
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 1, height: subIndex % 2 == 0 ? 4 : 2)
                    Spacer()
                }
            }.frame(height: zoneHeight * 0.8)

            if isInCurrentZone {
                PumpIndicator(currentHeartRate: currentHeartRate)
                    .offset(y: -geometry.size.height * 0.05)
            }
        }
    }
}
