//
//  Utils.swift
//  WatchKit App Extension
//
//  Created by kaoji on 5/2/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import SwiftUI

struct AppConfig {
    static let zoneColors: [Color] = [.green, .yellow, .orange, .red, .purple]
    static let zoneThresholds: [Int] = [60, 100, 120, 160, 190, 220]
    static let zoneDescriptions: [String] = ["静息", "轻松", "有氧", "高强", "极限"]
}

struct AppUtils {
    static func alignedTexts<T: Hashable>(items: [T], font: Font, color: Color, currentItem: T? = nil, currentItemColor: Color? = nil) -> some View {
        HStack {
            ForEach(items, id: \.self) { item in
                Text(String(describing: item))
                    .font(font)
                    .foregroundColor(currentItem == item && currentItemColor != nil ? currentItemColor! : color)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
            }
        }
    }
}
