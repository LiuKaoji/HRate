//
//  PersistManager.swift
//  BPM
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift
class PersistManager {
    static let shared = PersistManager()
    private let database: Database

    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let databasePath = documentsPath.appending("/HeartRate.db")
        database = Database(withPath: databasePath)

        createTablesIfNeeded()
    }

    // 如果数据库表不存在，则创建它们
    private func createTablesIfNeeded() {
        do {
            try database.create(table: "AudioEntity", of: AudioEntity.self)
        } catch {
            print("创建表错误：\(error)")
        }
    }

    // 保存音频
    func insertAudio(audioEntity: AudioEntity) {
        do {
            try database.insert(objects: audioEntity, intoTable: "AudioEntity")
        } catch {
            print("插入音频错误：\(error)")
        }
    }

    // 获取所有音频
    func fetchAllAudios() -> [AudioEntity] {
        do {
            return try database.getObjects(fromTable: "AudioEntity")
        } catch {
            print("获取音频错误：\(error)")
            return []
        }
    }
    
    // 删除音频实体
    func deleteAudio(audioEntity: AudioEntity) {
        guard let audioId = audioEntity.id else { return }
        do {
            try database.delete(fromTable: "AudioEntity", where: AudioEntity.CodingKeys.id == audioId)
        } catch {
            print("删除音频错误：\(error)")
        }
    }
}


extension PersistManager{
    
    // 新增录音并用于关联心跳数据
    func newAudioEntity()-> AudioEntity{
        let audio = AudioEntity()
        let date = TimeFormat.shared.currentDateString()
        audio.date = date
        audio.name = "REC - \(date).m4a"
        audio.ext = "m4a"
        
        return audio
    }
}
