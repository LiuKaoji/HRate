//
//  AppDelegate.swift
//  HeartRate
//
//  Created by kaoji on 10/9/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var recordVC: RecordController = RecordController()

    func applicationDidFinishLaunching(_ application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        application.registerForRemoteNotifications()
        
        // 启动时 激活 WCSession
        WatchConnectivityManager.shared?.activate()
        
        // 申请心率权限
        requestHeartRateAuthorization()
        
        // 显示窗口
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.rootViewController = recordVC
        window?.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(#function)
        self.application(application, performFetchWithCompletionHandler: completionHandler)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(#function)
        
        var didCompleted = false
        
        // 最大市场是 30秒, 设置 25 25秒.
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            guard !didCompleted else { return }
            didCompleted = true
            completionHandler(.noData)
        }
    }

    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        HKHealthStore().handleAuthorizationForExtension { _, error in
            if let error = error {
                print(error)
            }
        }
    }

    private func requestHeartRateAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
            let typesToShare: Set = [heartRateType]
            let typesToRead: Set = [heartRateType]
            
            HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                if let error = error {
                    print("Error requesting authorization: \(error.localizedDescription)")
                    //completion(false)
                } else {
                    //completion(success)
                }
            }
        } else {
            print("Health data is not available on this device.")
            //completion(false)
        }
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "HeartRate")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

