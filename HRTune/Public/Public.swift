//
//  Public.swift
//  HRTune
//
//  Created by kaoji on 4/27/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

@_exported import Foundation
@_exported import UIKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import SnapKit

func toByteString(_ size: UInt64) -> String {
    var convertedValue = Double(size)
    var multiplyFactor = 0
    let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    while convertedValue > 1024 {
        convertedValue /= 1024
        multiplyFactor += 1
    }
    return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
}

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
    
    // 默认的播放列表
    public var defaultPlaylistIndex: Int {
        get {
            // 用默认值 0，如果没有找到这个键的值，则返回0
            return UserDefaults.standard.integer(forKey: #function)
        } set {
            // 确保我们设置的值在预期的范围内
            assert(newValue >= 0 && newValue <= 2, "Invalid default playlist index.")
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }

}
