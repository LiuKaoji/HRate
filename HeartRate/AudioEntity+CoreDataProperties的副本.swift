//
//  AudioEntity+CoreDataProperties.swift
//  HeartRate
//
//  Created by kaoji on 4/8/23.
//  Copyright © 2023 Jonny. All rights reserved.
//
//

import Foundation
import CoreData


extension AudioEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioEntity> {
        return NSFetchRequest<AudioEntity>(entityName: "AudioEntity")
    }

    @NSManaged public var audioPath: String? //音频路径 默认存储在documents目录
    @NSManaged public var identify: String? //uuid唯一标识,该标识用于关联心跳数据
    @NSManaged public var startDate: String? //开始录制时间
    @NSManaged public var duration: String? //录音时长
    @NSManaged public var size: String?//文件大小
    @NSManaged public var maxBpm: Int16//录制期间最大心率
    @NSManaged public var minBPM: Int16//录制期间最小心率
    @NSManaged public var avgBPM: Int16//录制期间平均心率
    @NSManaged public var relationship: HeartRateEntity? //每个音频对应多组组心率数据

}

