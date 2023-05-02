//
//  UIButton + NoRepeat.swift
//  HRate
//
//  Created by kaoji on 5/2/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

private var clickIntervalKey: UInt8 = 0
private var lastClickTimeKey: UInt8 = 1

extension UIButton {
    @IBInspectable var clickInterval: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &clickIntervalKey) as? TimeInterval ?? 0.5
        }
        set {
            objc_setAssociatedObject(self, &clickIntervalKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var lastClickTime: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &lastClickTimeKey) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(self, &lastClickTimeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc dynamic private func noRepeat_sendAction(_ action: Selector, to target: AnyObject?, for event: UIEvent?) {
        let currentTime = Date().timeIntervalSinceReferenceDate

        if currentTime - lastClickTime >= clickInterval {
            lastClickTime = currentTime
            noRepeat_sendAction(action, to: target, for: event)
        }
    }

    class func setupNoRepeatClick() {
        let originalSelector = #selector(sendAction(_:to:for:))
        let swizzledSelector = #selector(noRepeat_sendAction(_:to:for:))

        let originalMethod = class_getInstanceMethod(UIButton.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UIButton.self, swizzledSelector)

        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

