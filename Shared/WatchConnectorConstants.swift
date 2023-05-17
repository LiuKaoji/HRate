//
//  WatchConnectivityConstants.swift
//  HRTune
//
//  Created by kaoji on 01/25/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

extension WatchConnector.MessageKey {
    
    // 启动关闭
    static let workoutStart = WatchConnector.MessageKey("Workout.start")//启动
    static let workoutStop = WatchConnector.MessageKey("Workout.stop")//关闭
    static let workoutError = WatchConnector.MessageKey("Workout.error")//失败
    
    // 用户信息传输
    static let workoutUserInfo = WatchConnector.MessageKey("Workout.userInfo")
    
    // 心率数据传输
    static let workoutData = WatchConnector.MessageKey("Workout.data")
    
    
//    //心率及卡路里
//    static let bpmValue = WatchConnector.MessageKey("HeartRate.bpmValue")//心率当前值
//    static let bpmDate = WatchConnector.MessageKey("HeartRate.bpmDate")//心率记录日期
}
