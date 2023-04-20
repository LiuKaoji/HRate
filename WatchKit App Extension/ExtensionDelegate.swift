//
//  ExtensionDelegate.swift
//  WatchKitApp Extension
//
//  Created by kaoji on 10/24/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchKit
import HealthKit
import ClockKit


class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // 应用程序启动时调用的方法
    func applicationDidFinishLaunching() {
        requestAuthorization({})
        scheduleBackgroundRefresh()
        WatchConnector.shared.activate()
    }
    
    // 处理来自 Watch App 的运动配置请求
    // 参数：workoutConfiguration 运动配置
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
//        if let root = WKExtension.shared().rootInterfaceController {
//            print("root class name: \(root.classForCoder)")
//            (root as? InterfaceController)?.onClickAction()
//        }else{
//            print("root class was nil")
//        }
        
        //多页的时候rootInterfaceController可能为空 为了解决这个bug暂时使用通知实现
        NotificationManager.shared.postActionNotification()
    }
    
    // 处理后台刷新任务
    // 参数：backgroundTasks 后台刷新任务集合
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            // 更新 complication 数据
            let complicationController = ComplicationController()
            complicationController.extendTimeline()
            
            // 重新调度下一次后台刷新
            scheduleBackgroundRefresh()
            
            // 完成后台任务
            task.setTaskCompletedWithSnapshot(false)
        }
    }
    
    // 调度后台刷新任务
    private func scheduleBackgroundRefresh() {
        let backgroundRefreshDate = Date(timeIntervalSinceNow: 60 * 60) // 您可以根据需要调整时间间隔
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: backgroundRefreshDate, userInfo: nil) { error in
            if let error = error {
                print("Failed to schedule background refresh: \(error.localizedDescription)")
            } else {
                print("Background refresh scheduled successfully.")
            }
        }
    }
    
    // 请求健康数据权限
    // 参数：handler 请求完成后的回调
    private func requestAuthorization(_ handler: @escaping () -> Void) {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes = Set([heartRateType])
        
        HKHealthStore().requestAuthorization(toShare: nil, read: readTypes) { success, error in
            handler()
            if let error = error {
                print(error)
            }
        }
    }
}
