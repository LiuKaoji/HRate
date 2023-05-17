//
//  TimeFormat.swift
//  HRTune
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation

// 时间格式化管理器
class TimeFormat {
    static let shared = TimeFormat() // 单例
    public let formatter: DateFormatter // 时间格式化对象
    private let timeZone: TimeZone // 时区对象
    
    // 初始化
    init() {
        formatter = DateFormatter()
        timeZone = TimeZone(identifier: "Asia/Shanghai") ?? TimeZone.current // 默认使用中国时区
        formatter.timeZone = timeZone
        setupFormatter() // 设置时间格式化对象的格式
    }
    
    // 设置时间格式化对象的格式
    private func setupFormatter(with format: String? = nil) {
        if let format = format {
            formatter.dateFormat = format
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH_mm_ss"
        }
    }
    
    // 获取当前时间戳
    func currentTimestamp() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    // 将时间戳转换为指定格式的时间字符串
    func timestampToString(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return formatter.string(from: date)
    }
    
    // 将指定格式的时间字符串转换为时间戳
    func stringToTimestamp(string: String) -> TimeInterval? {
        if let date = formatter.date(from: string) {
            return date.timeIntervalSince1970
        } else {
            return nil
        }
    }
    
    // 获取当前时间的指定格式字符串
    func currentDateString() -> String {
        return formatter.string(from: Date())
    }
    
    // 计算两个指定格式的时间字符串之间的差值（以秒为单位）
    func timeDifferenceBetweenStrings(string1: String, string2: String) -> TimeInterval? {
        if let date1 = formatter.date(from: string1),
           let date2 = formatter.date(from: string2) {
            return date1.timeIntervalSince(date2)
        } else {
            return nil
        }
    }
    
    // 格式化时间间隔为字符串
    class func formatTimeInterval(seconds: TimeInterval) -> String {
        let seconds = Int(seconds)
        guard seconds > 0 else { return "00:00" }
        
        let s = seconds % 60, m = seconds / 60 % 60, h = m/60
        var timeString = ""
        if h>0 {
            timeString.append(String(format: "%ld:%0.2ld", h, m))
            timeString.append(String(format: ":%0.2ld", s))
        } else {
            
            timeString.append(String(format: "%0.2ld", m))
            timeString.append(String(format: ":%0.2ld", s))
        }
        return timeString
    }
}
