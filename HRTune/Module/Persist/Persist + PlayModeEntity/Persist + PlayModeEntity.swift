//
//  Persist + PlayModeEntity.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

//MARK: - 播放模式相关
extension Persist {
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
