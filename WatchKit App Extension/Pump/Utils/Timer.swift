//
//  Timer.swift
//  WatchKit App Extension
//
//  Created by kaoji on 5/2/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var counter: Int = 0
    @Published var timeStr: String = "00:00"
    private var timer: AnyCancellable?

    func start() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.counter += 1
                self?.timeStr = (self?.formatTimeInterval(seconds: TimeInterval(self?.counter ?? 0)))!
            }
    }

    func stop() {
        timer?.cancel()
        counter = 0
        timeStr = "00:00"
    }
    
    // 格式化时间间隔为字符串
    func formatTimeInterval(seconds: TimeInterval) -> String {
        let seconds = Int(seconds)
        guard seconds > 0 else { return "00:00" }
        
        let s = seconds % 60, m = seconds / 60 % 60, h = m/60
        var timeString = ""
        if h>0 {
            timeString.append(String(format: "%ld:%0.2ld", h, m))
            timeString.append(String(format: ":%0.2ld", s))
        } else {
            
            timeString.append(String(format: "%0.2ld", m))
            timeString.append(String(format: ":%0.2ld", s))
        }
        return timeString
    }
}
