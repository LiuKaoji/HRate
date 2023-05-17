//
//  UIView  + fill.swift
//  HRTune
//
//  Created by kaoji on 5/12/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    func addConstraintsToFillSuperview(with view: UIView) {
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
