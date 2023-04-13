//
//  AudioEntity.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

final class AudioEntity: TableCodable {
    var id: Int? = 0 // Add an identifier
    var name: String? // 文件名
    var ext: String? // 扩展名
    var date: String? // 创建日期
    var duration: String = "00:00" // 录制时长
    var size: String = "0 KB" // 文件大小
    var maxBpm: Int16 = 0 // 最大心率
    var minBPM: Int16 = 0 // 最小心率
    var avgBPM: Int16 = 0 // 平均心率
    var audioId: String? = nil // Add an identifier

    enum CodingKeys: String, CodingTableKey {
        typealias Root = AudioEntity
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id, name, date, duration, size, maxBpm, minBPM, avgBPM
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                name: ColumnConstraintBinding(isUnique: true),
            ]
        }
    }
}

// Hashable conformance
extension AudioEntity: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AudioEntity, rhs: AudioEntity) -> Bool {
        return lhs.id == rhs.id
    }
}


