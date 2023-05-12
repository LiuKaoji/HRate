//
//  RecordHud.swift
//  AEAudio
//
//  Created by kaoji on 5/3/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

//import Foundation
//import UIKit
//
//class AERecordHUD: UIView {
//
//    // MARK: - Constants
//    private let HUDWidth: CGFloat = 170
//    private let HUDHeight: CGFloat = 78
//    private let HUDCornerRadius: CGFloat = 38
//    private let VolumeViewHeight = 40
//    private let VolumeViewWidth = 60
//
//    // MARK: - UI Elements
//    private let titleLabel = UILabel()
//    private let progress = AEProgressView()
//    private let volume = AEVolumeView()
//
//    // MARK: - Init
//    init() {
//        super.init(frame: CGRect(x: 0, y: 0, width: HUDWidth, height: HUDHeight))
//        center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 50)
//        backgroundColor = UIColor.clear
//
//        addSubview(progress)
//        addSubview(volume)
//        setUpLabel()
//        addSubview(titleLabel)
//        setUpShadow()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Public Methods
//    public func startCounting() {
//        progress.countingAnimate()
//        titleLabel.text = "Slide up to cancel"
//    }
//
//    public func stopCounting() {
//        progress.stopAnimate()
//    }
//
//    // MARK: - Setup
//    private func setUpLabel() {
//        titleLabel.textColor = UIColor.white
//        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
//        titleLabel.textAlignment = .center
//        titleLabel.backgroundColor = UIColor.clear
//        titleLabel.frame = CGRect(x: 25, y: 46, width: 120, height: 14)
//    }
//
//    private func setUpShadow() {
//        let progessViewBounds = progress.frame
//        let shadowWidth = progessViewBounds.size.width * 0.85
//        let shadowHeight = progessViewBounds.size.height * 0.75
//
//        let shadowPath = UIBezierPath(roundedRect: CGRect(x: progessViewBounds.origin.x + (progessViewBounds.width - shadowWidth) * 0.5,
//                                                          y: progessViewBounds.origin.y + 20,
//                                                          width: shadowWidth,
//                                                          height: shadowHeight),
//                                      cornerRadius: progress.layer.cornerRadius)
//
//        layer.shadowColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1).cgColor
//        layer.shadowPath = shadowPath.cgPath
//        layer.shadowOpacity = 0.5
//        layer.shadowRadius = 8
//        layer.shadowOffset = CGSize(width: 0, height: 10)
//    }
//}
//
//// MARK: - AEProgressView
//private class AEProgressView: UIImageView {
//    
//    private let progressLayer: CAShapeLayer
//    private let animation: CABasicAnimation
//    
//    override init(frame: CGRect) {
//        progressLayer = CAShapeLayer()
//        animation = CABasicAnimation(keyPath: "strokeEnd")
//        super.init(frame: frame)
//        setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func countingAnimate() {
//        progressLayer.add(animation, forKey: nil)
//    }
//    
//    func stopAnimate() {
//        progressLayer.removeAllAnimations()
//    }
//    
//    private func setup() {
//        // Configure view properties
//        layer.cornerRadius = 38
//        clipsToBounds = true
//        frame = CGRect(x: 0, y: 0, width: 170, height: 78)
//        
//        // Configure progressLayer
//        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: layer.cornerRadius)
//        let maskLayer = CAShapeLayer()
//        maskLayer.backgroundColor = UIColor.clear.cgColor
//        maskLayer.path = maskPath.cgPath
//        maskLayer.frame = bounds
//        
//        let progressPath = CGMutablePath()
//        progressPath.move(to: CGPoint(x: 0, y: frame.height / 2))
//        progressPath.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
//        
//        progressLayer.frame = bounds
//        progressLayer.fillColor = UIColor.clear.cgColor
//        progressLayer.strokeColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 0.90).cgColor
//        progressLayer.lineCap = .butt
//        progressLayer.lineWidth = 78
//        progressLayer.path = progressPath
//        progressLayer.mask = maskLayer
//        
//        layer.addSublayer(progressLayer)
//        
//        animation.duration = 60
//        animation.timingFunction = CAMediaTimingFunction(name: .linear)
//        animation.fillMode = .forwards
//        animation.fromValue = 0.0
//        animation.toValue = 1.0
//        animation.autoreverses = false
//        animation.repeatCount = 1
//    }
//}
//
//// MARK: - AEVolumeView
//class MCVolumeView: UIView {
//
//    private let volumeLayer = CALayer()
//    private let volumeGradientLayer = CAGradientLayer()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setup() {
//        backgroundColor = UIColor.clear
//        layer.cornerRadius = 6
//        clipsToBounds = true
//
//        volumeLayer.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 0)
//        volumeLayer.backgroundColor = UIColor.red.cgColor
//        layer.addSublayer(volumeLayer)
//
//        volumeGradientLayer.frame = bounds
//        volumeGradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor]
//        volumeGradientLayer.locations = [0.0, 0.5, 1.0]
//        volumeGradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
//        volumeGradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
//        layer.addSublayer(volumeGradientLayer)
//
//        volumeGradientLayer.mask = volumeLayer
//    }
//
//    func updateVolumeLevel(_ volume: CGFloat) {
//        let newHeight = frame.height * min(max(volume, 0), 1)
//        volumeLayer.frame = CGRect(x: 0, y: frame.height - newHeight, width: frame.width, height: newHeight)
//    }
//}
//
//
