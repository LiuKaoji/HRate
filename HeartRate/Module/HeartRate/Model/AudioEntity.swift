//
//  AudioEntity.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

struct BPMDescription: Codable{
    var bpm: Int16 = 0 // 心率
    var date: String? // 心率记录日期
    var ts: TimeInterval = 0 // 录音时间戳
}

// 记录一次训练过程的录音数据
final class AudioEntity: TableCodable {
    var id: Int? // 标识
    var name: String? // 文件名
    var ext: String? // 扩展名
    var date: String? // 创建日期
    var duration: String = "00:00" // 录制时长
    var size: String = "0 KB" // 文件大小
    var bpms: [BPMDescription] = [] // 心率数据

    enum CodingKeys: String, CodingTableKey {
        typealias Root = AudioEntity
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id, name, date, duration, size, ext, bpms
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                name: ColumnConstraintBinding(isUnique: true),
            ]
        }
    }
}

// 哈希协议 对比数据
extension AudioEntity: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AudioEntity, rhs: AudioEntity) -> Bool {
        return lhs.id == rhs.id
    }
}


