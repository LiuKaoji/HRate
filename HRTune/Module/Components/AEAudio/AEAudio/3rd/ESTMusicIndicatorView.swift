//
//  ESTMusicIndicatorView.swift
//  ESTMusicIndicator
//
//  Created by Aufree on 12/6/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

import UIKit

public enum ESTMusicIndicatorViewState: Int {
    case stopped    // 停止状态
    case playing    // 播放状态
    case paused     // 暂停状态
}

open class ESTMusicIndicatorView: UIView {

    open var hidesWhenStopped: Bool = true {
        didSet {
            if state == .stopped {
                isHidden = hidesWhenStopped
            }
        }
    }
    
    public var state: ESTMusicIndicatorViewState = .stopped {
        didSet {
            if state == .stopped {
                stopAnimating()
                if hidesWhenStopped {
                    isHidden = true
                }
            } else {
                if state == .playing {
                    startAnimating()
                } else {
                    stopAnimating()
                }
                isHidden = false
            }
        }
    }
    
    private var hasInstalledConstraints: Bool = false
    private var contentView:ESTMusicIndicatorContentView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.masksToBounds = true
        contentView = ESTMusicIndicatorContentView.init()
        addSubview(contentView)
        prepareLayoutPriorities()
        setNeedsUpdateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func prepareLayoutPriorities() {
        setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Auto Layout
    
    override open var intrinsicContentSize : CGSize {
        return contentView.intrinsicContentSize
    }
    
    override open func updateConstraints() {
        if !hasInstalledConstraints {
            addConstraint(NSLayoutConstraint(item: self,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: contentView,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: 0.0))
            
            addConstraint(NSLayoutConstraint(item: self,
                                        attribute: .centerY,
                                        relatedBy: .equal,
                                        toItem: contentView,
                                        attribute: .centerY,
                                        multiplier: 1.0,
                                        constant: 0.0))
            
            hasInstalledConstraints = true
        }
        super.updateConstraints()
    }
    
    // MARK: Frame-Based Layout
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    // MARK: Helpers
    
    private func startAnimating() {
        if contentView.isOscillating() {
            return
        }
        contentView.stopDecay()
        contentView.startOscillation()
    }
    
    private func stopAnimating() {
        if !contentView.isOscillating() {
            return
        }
        
        contentView.stopOscillation()
        contentView.startDecay()
    }
    
    // MARK: Notification
    
    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        stopAnimating()
    }
    
    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
        if state == .playing {
            startAnimating()
        }
    }
    
    // MARK: - viewForLastBaselineLayout
    
    open override var forLastBaselineLayout: UIView {
        return contentView
    }
}

