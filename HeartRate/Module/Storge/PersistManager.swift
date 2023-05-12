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
            try database.create(table: "UserEntity", of: UserEntity.self)
            try database.create(table: "PlayModeEntity", of: PlayModeEntity.self)
            try database.create(table: "RPMEntity", of: RPMEntity.self)
        } catch {
            print("创建表错误：\(error)")
        }
    }
}


//MARK: -录音相关
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
    
    func audioURLForEntity(with entity: AudioEntity)-> URL{
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsDirectory.appendingPathComponent(entity.name!)
        return audioURL
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
            return try database.getObjects(fromTable: "AudioEntity").sorted(by: { audioA, audioB in
                audioA.id ?? 0  > audioB.id ?? 0
            })
        } catch {
            print("获取音频错误：\(error)")
            return []
        }
    }
    
    // 删除音频实体
    func deleteAudio(audioEntity: AudioEntity) {
        guard let audioId = audioEntity.id else { return }
        try? FileManager.default.removeItem(at: audioURLForEntity(with: audioEntity))
        
        do {
            try database.delete(fromTable: "AudioEntity", where: AudioEntity.CodingKeys.id == audioId)
        } catch {
            print("删除音频错误：\(error)")
        }
    }
    
    // 更新音频
    func updateAudio(audioEntity: AudioEntity) {
        guard let audioId = audioEntity.id else { return }
        
        do {
            try database.update(table: "AudioEntity", on: UserEntity.CodingKeys.all, with: audioEntity, where: AudioEntity.CodingKeys.id == audioId)
        } catch {
            print("更新音频错误：\(error)")
        }
    }

}

//MARK: - 个人资料相关
extension PersistManager{
    
    func getUserInfo() -> UserEntity? {
        if let userInfo = fetchUserEntity()?.first {
            return userInfo
        } else {
            // 如果表中不存在，则创建新的用户信息
            do {
                let newUser = UserEntity(gender: 0, weight: 60, age: 30, height: 170)
                try database.insert(objects: newUser, intoTable: "UserEntity")
                return newUser
            } catch {
                print("创建UserEntity错误：\(error)")
                return nil
            }
        }
    }
    
    // 更新用户信息
    func updateUserInfo(gender: Int, weight: Int, age: Int, height: Int) {
        do {
            if let userInfo = getUserInfo()  {
                // 更新用户信息
                userInfo.gender = gender
                userInfo.weight = weight
                userInfo.age = age
                userInfo.height = height
                try database.update(table: "UserEntity", on: UserEntity.CodingKeys.all, with: userInfo)
            }
        } catch {
            print("更新用户信息错误：\(error)")
        }
    }
    
    // 内嵌函数 先查询是否有
    func fetchUserEntity()-> [UserEntity]?{
        do {
            return try database.getObjects(fromTable: "UserEntity")
        } catch {
            print("获取UserEntity错误：\(error)")
            return []
        }
    }
}

//MARK: - 播放模式相关
extension PersistManager {
    // 获取或创建并保存播放模式实体
    func getPlayModeEntity() -> PlayModeEntity {
        do {
            let playModeEntities: [PlayModeEntity] = try database.getObjects(fromTable: "PlayModeEntity")
            if let playModeEntity = playModeEntities.first {
                return playModeEntity
            } else {
                // 如果表中不存在，则创建新的播放模式实体
                let newPlayModeEntity = PlayModeEntity()
                try database.insert(objects: newPlayModeEntity, intoTable: "PlayModeEntity")
                return newPlayModeEntity
            }
        } catch {
            print("获取PlayModeEntity错误：\(error)")
            let newPlayModeEntity = PlayModeEntity()
            try? database.insert(objects: newPlayModeEntity, intoTable: "PlayModeEntity")
            return newPlayModeEntity
        }
    }


    // 保存播放模式实体
    func savePlayModeEntity(_ playModeEntity: PlayModeEntity) {
        do {
            try database.update(table: "PlayModeEntity", on: PlayModeEntity.CodingKeys.all, with: playModeEntity)
        } catch {
            print("保存PlayModeEntity错误：\(error)")
        }
    }
}

//MARK: - 自定义音频包相关
extension PersistManager {
    
    func loadAllMusicInfos() -> [MusicInfo] {
        var allMusicInfos: [MusicInfo] = []

        // 获取所有的 RPMEntities
        guard let rpmEntities = loadRPMEntities() else {
            return allMusicInfos
        }

        // 遍历 RPMEntities 并提取 musicInfo 属性
        for rpmEntity in rpmEntities {
            let musicInfo = rpmEntity.musicInfo
            allMusicInfos.append(contentsOf: musicInfo)
        }

        // 对 allMusicInfos 进行排序
        allMusicInfos.sort { (musicInfo1, musicInfo2) -> Bool in
            if musicInfo1.albumName == musicInfo2.albumName {
                return musicInfo1.serialNumber < musicInfo2.serialNumber
            } else {
                return musicInfo1.albumName > musicInfo2.albumName
            }
        }

        return allMusicInfos
    }


    // 保存音乐包到数据库
    func saveRPMEntitiesToDatabase(_ rpmEntities: [RPMEntity]) {
        do {
            for rpmEntity in rpmEntities {
                try database.insert(objects: rpmEntity, intoTable: "RPMEntity")
            }
        } catch {
            print("Error saving data to database: \(error)")
        }
    }

    // 从数据库获取所有音乐包
    func fetchRPMEntitiesFromDatabase() -> [RPMEntity]? {
        do {
            let entities: [RPMEntity] = try database.getObjects(fromTable: "RPMEntity")
            return entities
        } catch {
            print("Error fetching data from database: \(error)")
            return nil
        }
    }

    // 从 Bundle 或数据库加载音乐包
    func loadRPMEntities() -> [RPMEntity]? {
        let rpmEntitiesFromDatabase = fetchRPMEntitiesFromDatabase()

        if let rpmEntities = rpmEntitiesFromDatabase, !rpmEntities.isEmpty {
            return rpmEntities
        } else {
            let rpmEntitiesFromBundle = RPMResources.loadRPMEntities()

            if let rpmEntities = rpmEntitiesFromBundle {
                saveRPMEntitiesToDatabase(rpmEntities)
                return rpmEntities
            } else {
                return nil
            }
        }
    }

    // 删除音乐包
    func deleteRPMEntity(_ rpmEntity: RPMEntity) {
        guard let entityId = rpmEntity.id else { return }
        do {
            try database.delete(fromTable: "RPMEntity", where: RPMEntity.CodingKeys.id == entityId)
        } catch {
            print("Error deleting rpm entity: \(error)")
        }
    }
}
