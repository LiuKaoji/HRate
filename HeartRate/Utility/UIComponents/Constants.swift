//
//  Constants.swift
//  HeartRate
//
//  Created by kaoji on 11/22/21.
//

import UIKit

// 常量类，使用单例模式
public class Constants {
    
    public static let shared = Constants()
    
    // 是否在启动时启用记录功能
    public var isRecordingAtLaunchEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: #function)
        } set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    // 是否是第一次启动应用
    public var isFirstLaunch: Bool {
        get {
            UserDefaults.standard.bool(forKey: #function)
        } set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    // 是否是大屏幕设备
    public var isBig: Bool {
        if screenSize.height > 667 {
            return true
        } else {
            return false
        }
    }
    
    // 设备屏幕尺寸
    public var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
}

func HRToast(message: String, duration: TimeInterval = 2.0, position: ToastPosition = .center) {
    if let topWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        topWindow.makeToast(message, duration: duration, position: position)
    }
}
