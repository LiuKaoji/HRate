//
//  AudioEntity.swift
//  HRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

public struct BPMDescription: Codable{
    var bpm: Int = 0 // 心率
    var date: String? // 心率记录日期
    var ts: TimeInterval = 0 // 录音时间戳
    var max: Int = 0   //最大心率
    var min: Int = 0  //最小心率
    var avg: Int = 0  //平均心率
    var kcal: Int = 0 //总消耗
    
    mutating func set(with data: WorkoutData){
        bpm = data.nowBPM
        date = TimeFormat.shared.currentDateString()
        max = data.maxBPM
        min = data.maxBPM
        kcal = Int(data.totalCalories)
    }
}

// 记录一次训练过程的录音数据
final public class AudioEntity: TableCodable {
    var id: Int? // 标识
    var name: String? // 文件名
    var ext: String? // 扩展名
    var date: String? // 创建日期
    var duration: String = "00:00" // 录制时长
    var size: String = "0 KB" // 文件大小
    var bpms: [BPMDescription] = [] // 心率数据
    
    var assetURL: URL? // 媒体资源 URL


    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = AudioEntity
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id, name, date, duration, size, ext, bpms
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                name: ColumnConstraintBinding(isUnique: true),
            ]
        }
    }
}

// 哈希协议 对比数据
extension AudioEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: AudioEntity, rhs: AudioEntity) -> Bool {
        return lhs.id == rhs.id
    }
}


extension AudioEntity {
    
    func audioURL()-> URL {
        if let assetURL = assetURL {
            return assetURL
        }
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsDirectory.appendingPathComponent(self.name!)
        return audioURL
    }
}
