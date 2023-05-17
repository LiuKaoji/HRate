//
//  AppDelegate.swift
//  HRTune
//
//  Created by kaoji on 10/9/16.
//  Copyright © 2023 kaoji. All rights reserved.
//

import UIKit
import HealthKit
import CoreData
import BackgroundTasks
import MediaPlayer


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var recordVC: RecordController = RecordController()

    func applicationDidFinishLaunching(_ application: UIApplication) {

        //注册控制中心显示歌曲信息
//        AudioLibraryManager.shared.requestAuthorization { state in
//            
//        }
//        Persist.shared.fetchAllAudios().forEach { audio in
//            Persist.shared.deleteAudio(audioEntity: audio)
//        }

        // 创建一个窗口并设置根视图控制器
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.rootViewController = UINavigationController.init(rootViewController: recordVC)
        window?.makeKeyAndVisible()

        SplashView.show(iconImage: R.image.splash()!, backgroundColor: .white)
    }
    
    // 申请访问健康数据的权限
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
            
            // 请求权限来分享和读取心率数据
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
    
    // MARK: - 自定义方法
    
    func setupGlobalNavigationBarStyle() {
        // 获取全局导航栏的外观代理
        let navigationBarAppearance = UINavigationBar.appearance()
        
        // 设置导航栏背景颜色
        navigationBarAppearance.barTintColor = RecordViewConfig.backgroundColor
        
        // 设置导航栏标题字体和颜色
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        ]
        
        // 设置导航栏按钮字体和颜色
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)
        ], for: .normal)
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

