//
//  GuideItem.swift
//  HRTune
//
//  Created by kaoji on 5/15/23.
//  Copyright © 2023 kaoji. All rights reserved.
//


import Foundation

enum GuideItem: String, PVItemType {
    case iphoneBase
    case screen1
    case screen2
    case screen3
    case screen4
    case screen5
    case searchBubble
    case contactIcon
    case messageIcon
    case callingIcon
    case taskBubble
    case iWatch
    case label0
    case label1
    case label2
    case label3
    case label4
    case label5
    
    var identifier: String {
        return self.rawValue
    }
}
