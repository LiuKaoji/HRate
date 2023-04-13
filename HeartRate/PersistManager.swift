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

    // 创建数据库表
    private func createTablesIfNeeded() {
        do {
            try database.create(table: "AudioEntity", of: AudioEntity.self)
            try database.create(table: "BPMEntity", of: BPMEntity.self)
        } catch {
            print("Error creating tables: \(error)")
        }
    }

    // 保存音频
    func insertAudio(audioEntity: AudioEntity) {
        do {
            try database.insert(objects: audioEntity, intoTable: "AudioEntity")
        } catch {
            print("Error inserting audio: \(error)")
        }
    }

    // 查找所有音频
    func fetchAllAudios() -> [AudioEntity] {
        do {
            return try database.getObjects(fromTable: "AudioEntity")
        } catch {
            print("Error fetching audios: \(error)")
            return []
        }
    }
    
    func fetchAllAudiosWithBPMs() -> [AudioEntity: [BPMEntity]] {
        do {
            let audios: [AudioEntity] = try database.getObjects(fromTable: "AudioEntity")
            var audiosWithBPMs: [AudioEntity: [BPMEntity]] = [:]

            for audio in audios {
                let bpms = fetchBPMs(forAudio: audio)
                audiosWithBPMs[audio] = bpms
            }

            return audiosWithBPMs
        } catch {
            print("Error fetching audios and BPMs: \(error)")
            return [:]
        }
    }


    // 保存音频实体
    func deleteAudio(audioEntity: AudioEntity) {
        guard let audioId = audioEntity.audioId else { return }
        do {
            try database.delete(fromTable: "AudioEntity", where: AudioEntity.CodingKeys.id == audioId)
        } catch {
            print("Error deleting audio: \(error)")
        }
    }

    // 保存BPM实体
    func insertBPM(bpmEntity: BPMEntity) {
        do {
            try database.insert(objects: bpmEntity, intoTable: "BPMEntity")
        } catch {
            print("Error inserting heart rate: \(error)")
        }
    }

    // 查找所有心率
    func fetchAllBPMs() -> [BPMEntity] {
        do {
            return try database.getObjects(fromTable: "BPMEntity")
        } catch {
            print("Error fetching heart rates: \(error)")
            return []
        }
    }

    // 删除一个心率实体
    func deleteBPM(bpmEntity: BPMEntity) {
        guard let bpmId = bpmEntity.audioId else { return }
        do {
            try database.delete(fromTable: "BPMEntity", where: BPMEntity.CodingKeys.audioId == bpmId)
        } catch {
            print("Error deleting heart rate: \(error)")
        }
    }

    // 通过音频实体查找所有关联心率数据
    func fetchBPMs(forAudio audio: AudioEntity) -> [BPMEntity] {
        guard let audioId = audio.audioId else { return [] }
        do {
            return try database.getObjects(fromTable: "BPMEntity", where: BPMEntity.CodingKeys.id == audioId)
        } catch {
            print("Error fetching heart rates: \(error)")
            return []
        }
    }

    // 保存心跳至指定的音频实体
    func saveBPMs(_ heartRates: [BPMEntity], forAudio audio: AudioEntity) {
        guard let audioId = audio.audioId else { return }
        heartRates.forEach { $0.audioId = audioId }
        do {
            try database.insert(objects: heartRates, intoTable: "BPMEntity")
        } catch {
            print("Error saving heart rates: \(error)")
        }
    }
}

