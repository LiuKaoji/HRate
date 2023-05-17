//
//  Persist.swift
//  BPM
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift
import AEAudio


class Persist {
    static let shared = Persist()
    public let database: Database

    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let databasePath = documentsPath.appending("/HeartRate.db")
        database = Database(withPath: databasePath)

        createTablesIfNeeded()
        loadMusicInfosIfNeeded()
    }

    // 如果数据库表不存在，则创建它们
    private func createTablesIfNeeded() {
        do {
            try database.create(table: "AudioEntity", of: AudioEntity.self)
            try database.create(table: "UserEntity", of: UserEntity.self)
            try database.create(table: "PlayModeEntity", of: PlayModeEntity.self)
            try database.create(table: "MusicInfo", of: MusicInfo.self)
        } catch {
            print("创建表错误：\(error)")
        }
    }
}


