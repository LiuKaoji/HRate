//
//  WatchConnectivityConstants.swift
//  HeartRate
//
//  Created by kaoji on 01/25/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

extension WatchConnectivityManager.MessageKey {
    
    static let workoutStart = WatchConnectivityManager.MessageKey("Workout.start")
    static let workoutStop = WatchConnectivityManager.MessageKey("Workout.stop")
    static let workoutError = WatchConnectivityManager.MessageKey("Workout.error")
    
    static let heartRateIntergerValue = WatchConnectivityManager.MessageKey("HeartRate.intergerValue")
    static let heartRateRecordDate = WatchConnectivityManager.MessageKey("HeartRate.recordDate")
    
}
