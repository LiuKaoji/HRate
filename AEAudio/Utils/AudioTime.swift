//
//  AudioTime.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

// 秒数格式化成字符串
@objc public class AudioTime: NSObject {
    class func format(_ seconds: TimeInterval) -> String {
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
