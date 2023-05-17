//
//  UITableView.swift
//  HRTune
//
//  Created by kaoji on 4/26/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

private var emptyStateViewKey: UInt8 = 0

extension UITableView {
    var emptyStateView: UIView? {
        get {
            return objc_getAssociatedObject(self, &emptyStateViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &emptyStateViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setEmptyStateViewVisible(_ visible: Bool) {
        if visible {
            if let emptyStateView = emptyStateView {
                backgroundView = emptyStateView
            } else {
                let label = UILabel()
                label.text = "没有文件"
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 20)
                label.textColor = .lightGray
                backgroundView = label
                emptyStateView = label
            }
        } else {
            backgroundView = nil
        }
    }
}
