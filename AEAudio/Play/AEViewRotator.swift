//
//  ViewRotate.swift
//  BeatRider
//
//  Created by kaoji on 4/16/23.
//

import UIKit

class AEViewRotator {
    private var view: UIView
    private var rotateSpeed: CGFloat
    private var rotateAngle: CGFloat = 0
    private var isRunning = false
    private var timer: Timer?
    
    init(view: UIView, rotateSpeed: CGFloat = 0.01) {
        self.view = view
        self.rotateSpeed = rotateSpeed
    }
    
    public func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.rotateAngle += self.rotateSpeed
            self.view.transform = CGAffineTransform(rotationAngle: self.rotateAngle)
        }
    }
    
    public func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        start()
    }
    
    func getRotateAngle() -> CGFloat {
        return rotateAngle
    }
}
