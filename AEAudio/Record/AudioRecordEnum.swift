//
//  AudioRecordEnum.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

@objc public enum AudioRecordStatus: NSInteger {
    case idle = 0
    case prepared
    case recording
    case stopped
    case errorOccured
}
