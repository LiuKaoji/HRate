//
//  WatchConnectivityConstants.swift
//  HeartRate
//
//  Created by kaoji on 01/25/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

extension WatchConnector.MessageKey {
    
    static let workoutStart = WatchConnector.MessageKey("Workout.start")
    static let workoutStop = WatchConnector.MessageKey("Workout.stop")
    static let workoutError = WatchConnector.MessageKey("Workout.error")
    
    static let heartRateIntergerValue = WatchConnector.MessageKey("HeartRate.intergerValue")
    static let heartRateRecordDate = WatchConnector.MessageKey("HeartRate.recordDate")
    
}
