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

    func applicationDidFinishLaunching() {
        requestAuthorization({})
        scheduleBackgroundRefresh()
        WatchConnectivityManager.shared.activate()
    }
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        let root = WKExtension.shared().rootInterfaceController as! InterfaceController
        root.startWorkout(with: workoutConfiguration)
    }

//    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
//        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
//        for task in backgroundTasks {
//            // Use a switch statement to check the task type
//            switch task {
//            case let backgroundTask as WKApplicationRefreshBackgroundTask:
//                // Be sure to complete the background task once you’re done.
//                backgroundTask.setTaskCompletedWithSnapshot(true )
//            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
//                // Snapshot tasks have a unique completion call, make sure to set your expiration date
//                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
//            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
//                // Be sure to complete the connectivity task once you’re done.
//                connectivityTask.setTaskCompletedWithSnapshot(true)
//            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
//                // Be sure to complete the URL session task once you’re done.
//                urlSessionTask.setTaskCompletedWithSnapshot(true)
//            default:
//                // make sure to complete unhandled task types
//                task.setTaskCompletedWithSnapshot(true)
//            }
//        }
//    }
    
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


    func scheduleBackgroundRefresh() {
        let backgroundRefreshDate = Date(timeIntervalSinceNow: 60 * 60) // 您可以根据需要调整时间间隔
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: backgroundRefreshDate, userInfo: nil) { error in
            if let error = error {
                print("Failed to schedule background refresh: \(error.localizedDescription)")
            } else {
                print("Background refresh scheduled successfully.")
            }
        }
    }
    
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
