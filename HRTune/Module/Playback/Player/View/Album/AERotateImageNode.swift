//
//  AERotateImageNode.swift
//  HRTune
//
//  Created by kaoji on 5/4/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public class AERotateImageNode: ASImageNode {
    private var rotateSpeed: CGFloat
    private var rotateAngle: CGFloat = 0
    private var isRunning = false
    private var timer: CADisplayLink?
    public  var sharedCallback: (() -> Void)?
    private var isManuallyPaused = false
    private var isInBackground = false
    
    public init(rotateSpeed: CGFloat = 0.01) {
        self.rotateSpeed = rotateSpeed
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func startRotate() {
        guard !isRunning else { return }
        isRunning = true
        timer = CADisplayLink(target: self, selector: #selector(updateRotation))
        timer?.add(to: .main, forMode: .common)
    }

    public func pauseRotate() {
        isManuallyPaused = true
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    public func innerPauseRotate() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    @objc private func didEnterBackground() {
        isInBackground = true
        if isRunning && !isManuallyPaused {
            innerPauseRotate()
        }
    }

    @objc private func didBecomeActive() {
        if isInBackground {
            isInBackground = false
            if isRunning && !isManuallyPaused {
                startRotate()
            }
        }
    }

    
    @objc private func updateRotation() {
        rotateAngle += rotateSpeed
        self.transform = CATransform3DMakeRotation(rotateAngle, 0, 0, 1)
        sharedCallback?()
    }
}
