//
//  OSTimer.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/19/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation

open class OSTimer {
    private var timer: Timer?
    private(set) var secondsElapsed: Int = 0
    private var timerCallback: ((Int) -> Void)?
    private var loop: TimeInterval = 0.1

    public init(loop: TimeInterval,timerCallback: ((Int) -> Void)?) {
        self.loop = loop
        self.timerCallback = timerCallback
    }

    public func start() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: self.loop, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        }
    }

    public func stop() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    public func reset() {
        secondsElapsed = 0
    }

    @objc private func timerTick() {
        secondsElapsed += 1
        timerCallback?(secondsElapsed)
    }
}

