//
//  AudioPlayable.swift
//  AEAudio
//
//  Created by kaoji on 5/7/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

public protocol AudioPlayable {
    func audioName() -> String // 文件标题
    func audioDurationText() -> String // 文件时长
    func audioDuration() -> Double // 文件时长
    func audioURL() -> URL? //文件真实路径 如果获取不到 说明文件不存在
    func audioSize() -> String // 文件大小
    func remove() // 删除文件
    func markFavor() // 标记收藏
    func unMarkFavor() // 取消收藏
}
