//
//  UIStackView + Style.swift
//  HRTune
//
//  Created by kaoji on 5/12/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
// 扩展 UIStackView 以简化初始化和配置
extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) {
        self.init()
        self.axis = axis
        self.spacing = spacing
        self.distribution = .fill
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}
