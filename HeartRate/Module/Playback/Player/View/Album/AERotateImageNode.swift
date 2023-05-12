//
//  AERotateImageNode.swift
//  HRate
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
    public var sharedCallback: (() -> Void)? // Add a shared callback property

    public init(rotateSpeed: CGFloat = 0.01) {
        self.rotateSpeed = rotateSpeed
        super.init()
    }

    public func startRotate() {
        guard !isRunning else { return }
        isRunning = true
        timer = CADisplayLink(target: self, selector: #selector(updateRotation))
        timer?.add(to: .main, forMode: .common)
    }

    public func pauseRotate() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateRotation() {
        rotateAngle += rotateSpeed
        self.transform = CATransform3DMakeRotation(rotateAngle, 0, 0, 1)
        sharedCallback?() // Call the shared callback if it exists

    }
}
