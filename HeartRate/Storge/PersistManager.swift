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
        } catch {
            print("创建表错误：\(error)")
        }
    }
}


//MARK: - 音频相关
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
            return try database.getObjects(fromTable: "AudioEntity")
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
