//
//  PumpIndicator.swift
//  WatchKit App Extension
//
//  Created by kaoji on 5/2/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct PumpIndicator: View {
    let currentHeartRate: Int
    @State private var scalingAnimation: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
            
            Image(systemName: "heart.fill")
                .resizable()
                .foregroundColor(.red)
                .frame(width: 7, height: 7)
                .scaleEffect(scalingAnimation ? 1.2 : 1.0)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true))
                .onAppear {
                    scalingAnimation = true
                }
        }
        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
    }
}
