//
//  HRToast.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

enum ToastType {
    case success
    case error
    case warning
}

func HRToast(message: String, type: ToastType, duration: TimeInterval = 2.0, position: ToastPosition = .center) {
    guard !message.isEmpty else { return }
    if let topWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        // 根据类型设置 Toast 样式
        var style = ToastStyle()
        switch type {
        case .success:
            style.backgroundColor = .systemGreen
            style.messageColor = .white
        case .error:
            style.backgroundColor = .systemRed
            style.messageColor = .white
        case .warning:
            style.backgroundColor = .systemOrange
            style.messageColor = .white
        }
        
        topWindow.makeToast(message, duration: duration, position: position, style: style)
    } 
}
