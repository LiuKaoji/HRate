//
//  AudioPlayerEnum.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

@objc public enum AudioPlayerStatus: Int {
    case idle = 0
    case prepared
    case playing
    case paused
    case stopped
    case errorOccured
}

@objc public enum AudioPlayerError: Int {
    case audioFileError = 0
    case audioEngineError
    case audioPlayerError
    
    var message: String {
        switch self {
        case .audioFileError:
            return "Audio File Error"
        case .audioEngineError:
            return "Audio Engine Error"
        case .audioPlayerError:
            return "Audio Player Error"
        }
    }
    
    var messageCN: String {
        switch self {
        case .audioFileError:
            return "文件打开失败"
        case .audioEngineError:
            return "音频引擎错误"
        case .audioPlayerError:
            return "播放器错误"
        }
    }
}

