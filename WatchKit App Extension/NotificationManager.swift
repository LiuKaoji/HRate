//
//  NotificationManager.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/19/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import HealthKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 通知名称
    private let sampleNotificationName = Notification.Name("SampleNotification")//心率数据传递
    private let startNotificationName = Notification.Name("StartNotification")//开始检测心率
    private let stopNotificationName = Notification.Name("StopNotification")//停止检测心率
    private let pageNotificationName = Notification.Name("pageSwitch")//跳转页面
    private let actionNotificationName = Notification.Name("ActionNotification")//来自扩展的事件
    
    // 发送通知并传递数据
    func postSampleNotification(with samples: [HKQuantitySample]) {
        NotificationCenter.default.post(name: sampleNotificationName, object: nil, userInfo: ["samples": samples])
    }
    
    func postStartNotification() {
        NotificationCenter.default.post(name: startNotificationName, object: nil)
    }
    
    func postStopNotification() {
        NotificationCenter.default.post(name: stopNotificationName, object: nil)
    }
    
    func postPageSwitchNotification(classType: AnyClass) {
        NotificationCenter.default.post(name: pageNotificationName, object: nil, userInfo: ["classType": classType])
    }
    
    func postActionNotification() {
        NotificationCenter.default.post(name: actionNotificationName, object: nil)
    }
    
    // 订阅通知并在接收到通知时使用闭包处理数据
    func subscribeToSampleNotification(using callback: @escaping ([HKQuantitySample]) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: sampleNotificationName, object: nil, queue: .main) { notification in
            if let samples = notification.userInfo?["samples"] as? [HKQuantitySample] {
                callback(samples)
            }
        }
    }
    
    func subscribeToStartNotification(using callback: @escaping () -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: startNotificationName, object: nil, queue: .main) { _ in
            callback()
        }
    }
    
    func subscribeToStopNotification(using callback: @escaping () -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: stopNotificationName, object: nil, queue: .main) { _ in
            callback()
        }
    }
    
    func subscribeToPageSwitchNotification(forClass targetClass: AnyClass, using callback: @escaping (AnyClass) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: pageNotificationName, object: nil, queue: .main) { notification in
            if let classType = notification.userInfo?["classType"] as? AnyClass, targetClass == classType {
                callback(classType)
            }
        }
    }
    
    
    func subscribeToActionNotification(using callback: @escaping () -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: actionNotificationName, object: nil, queue: .main) { _ in
            callback()
        }
    }
    
    // 取消订阅通知
    func unsubscribeFromSampleNotification(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func unsubscribeFromStartNotification(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func unsubscribeFromStopNotification(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func unsubscribeFromPageSwitchNotification(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func unsubscribeFromActionNotification(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
}
