//
//  NotificationManager.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/19/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import HealthKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    enum NotificationName: String {
        case start = "start" //开始监测心率
        case stop = "stop" //停止监测心率
        case sample = "sample" //收到新的心率样本
        
        case pageSwitch = "pageSwitch" //页面切换
        case action = "extAction" // 来自EXTENSIIONDDelegate唤醒watchAPP的方法
        case userInfo = "userInfo" // 更新计算卡路里用户信息
        
        var name: Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }
    
    // 发送通知并传递数据
    func postNotification(_ notificationName: NotificationName, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: notificationName.name, object: object, userInfo: userInfo)
    }
    
    // 订阅或取消订阅通知
    func handleSubscription(for notificationName: NotificationName, action: SubscribeAction, callback: @escaping (Any?) -> Void) -> NSObjectProtocol? {
        switch action {
        case .subscribe:
            return NotificationCenter.default.addObserver(forName: notificationName.name, object: nil, queue: .main) { notification in
                callback(notification.object)
            }
        case .unsubscribe(let observer):
            NotificationCenter.default.removeObserver(observer)
            return nil
        }
    }
    
    enum SubscribeAction {
        case subscribe
        case unsubscribe(observer: NSObjectProtocol)
    }
}
