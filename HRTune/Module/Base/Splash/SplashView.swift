//
//  SplashView.swift
//  HRTune
//
//  Created by kaoji on 5/15/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit

// 定义动画的类型，提供两种类型：Twitter和心跳
enum AnimationType {
    case twitter
    case heartBeat
}


class SplashView: UIView {

    open var iconImage: UIImage? {
        didSet {
            imageView?.image = useCustomIconColor ? iconImage?.withRenderingMode(.alwaysTemplate) : iconImage
        }
    }
    
    open var iconColor: UIColor = .white {
        didSet {
            imageView?.tintColor = iconColor
        }
    }
    
    open var useCustomIconColor = false
    open var iconInitialSize: CGSize = CGSize(width: 60, height: 60) {
        didSet {
            imageView?.frame = CGRect(origin: .zero, size: iconInitialSize)
        }
    }
    
    open var backgroundImageView: UIImageView?
    open var imageView: UIImageView? = UIImageView()
    open var animationType: AnimationType = .twitter
    open var duration: Double = 1.5
    open var delay: Double = 0.5
    open var heartAttack = false
    open var minimumBeats = 1

    // 初始化
    public init(iconImage: UIImage,
                iconInitialSize: CGSize = CGSize(width: 60, height: 60),
                backgroundColor: UIColor,
                duration: Double = 2.0,
                animationType: AnimationType = .heartBeat,
                iconColor: UIColor = .red,
                useCustomIconColor: Bool = false) {
        super.init(frame: UIScreen.main.bounds)
        setupImageView(iconImage: iconImage, iconInitialSize: iconInitialSize)
        self.backgroundColor = backgroundColor
        self.duration = duration
        self.animationType = animationType
        self.iconColor = iconColor
        self.useCustomIconColor = useCustomIconColor
    }

    // 使用背景图初始化
    public init(iconImage: UIImage, iconInitialSize: CGSize, backgroundImage: UIImage) {
        super.init(frame: UIScreen.main.bounds)
        setupImageView(iconImage: iconImage, iconInitialSize: iconInitialSize)
        setupBackgroundImageView(backgroundImage: backgroundImage)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView(iconImage: UIImage, iconInitialSize: CGSize) {
        self.iconImage = iconImage
        self.iconInitialSize = iconInitialSize
        imageView?.contentMode = .scaleAspectFit
        imageView?.center = center
        addSubview(imageView!)
    }

    private func setupBackgroundImageView(backgroundImage: UIImage) {
        backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView?.frame = UIScreen.main.bounds
        backgroundImageView?.contentMode = .scaleAspectFill
        addSubview(backgroundImageView!)
        bringSubviewToFront(imageView!)
    }
}


// MARK: - SplashView Class extension to start the animation
public typealias AnimationCompletion = () -> Void
public typealias AnimationExecution = () -> Void

extension SplashView {
    
    // 开始动画，动画类型取决于animationType的值
    public func startAnimation(_ completion: AnimationCompletion? = nil) {
        switch animationType {
        case .twitter:
            playTwitterAnimation(completion)
        case .heartBeat:
            playHeartBeatAnimation(completion)
        }
    }
    
    // 执行Twitter动画
    public func playTwitterAnimation(_ completion: AnimationCompletion? = nil) {
        guard let imageView = self.imageView else { return }
        
        let shrinkDuration: TimeInterval = duration * 0.3
        
        UIView.animate(withDuration: shrinkDuration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: [], animations: {
            imageView.transform = CGAffineTransform(scaleX: 0.75,y: 0.75)
        }, completion: { _ in
            self.playZoomOutAnimation(completion)
        })
    }
    
    // 执行Zoom out动画
    public func playZoomOutAnimation(_ completion: AnimationCompletion? = nil) {
        guard let imageView =  imageView else { return }
        
        UIView.animate(withDuration: duration * 0.2, animations:{
            imageView.transform = CGAffineTransform(scaleX: 20, y: 20)
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
    
    // 执行心跳动画
    public func playHeartBeatAnimation(_ completion: AnimationCompletion? = nil) {
        guard let imageView = self.imageView else { return }
        
        animateLayer({
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [0, 0.1 * 1.5, 0.015 * 1.5, 0.2 * 1.5, 0]
            animation.keyTimes = [0, 0.25, 0.50, 0.75, 1]
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.duration = CFTimeInterval(self.duration/2)
            animation.isAdditive = true
            animation.repeatCount = Float(self.minimumBeats > 0 ? self.minimumBeats : 1)
            animation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay/2)
            imageView.layer.add(animation, forKey: "pop")
        }, completion: { [weak self] in
            self?.playZoomOutAnimation(completion)
        })
    }
    
    // 结束心跳动画
    public func finishHeartBeatAnimation() {
        self.heartAttack = true
    }
    
    // 执行动画层动画
    fileprivate func animateLayer(_ animation: AnimationExecution, completion: AnimationCompletion? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock { completion?() }
        animation()
        CATransaction.commit()
    }
}

extension SplashView {
    static func show(iconImage: UIImage,
                     iconInitialSize: CGSize = CGSize(width: 60, height: 60),
                     backgroundColor: UIColor,
                     duration: Double = 2.0,
                     animationType: AnimationType = .heartBeat,
                     iconColor: UIColor = .red,
                     useCustomIconColor: Bool = false,
                     completion: (() -> Void)? = nil) {
        
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let splashView = SplashView(iconImage: iconImage,
                                    iconInitialSize: iconInitialSize,
                                    backgroundColor: backgroundColor,
                                    duration: duration,
                                    animationType: animationType,
                                    iconColor: iconColor,
                                    useCustomIconColor: useCustomIconColor)
        
        keyWindow.addSubview(splashView)

        splashView.startAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                splashView.removeFromSuperview()
                completion?()
            }
        }
    }
}
