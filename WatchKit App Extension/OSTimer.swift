//
//  OSTimer.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/19/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

class OSTimer {
    private var timer: Timer?
    private(set) var secondsElapsed: Int = 0
    private var timerCallback: ((Int) -> Void)?

    init(timerCallback: ((Int) -> Void)?) {
        self.timerCallback = timerCallback
    }

    func start() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        }
    }

    func stop() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func reset() {
        secondsElapsed = 0
    }

    @objc private func timerTick() {
        secondsElapsed += 1
        timerCallback?(secondsElapsed)
    }
}

