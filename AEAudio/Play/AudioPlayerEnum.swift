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
    case finished
}


@objc public enum AudioPlayerError: Int {
      case audioEngineError
      case invalidURL
      case fileReadingError
      case otherError
      
      public func message()-> String {
          switch self {
          case .audioEngineError:
              return "音频引擎错误。"
          case .invalidURL:
              return "无效的URL。"
          case .fileReadingError:
              return "文件读取错误。"
          case .otherError:
              return "其他错误。"
          }
      }
  }
