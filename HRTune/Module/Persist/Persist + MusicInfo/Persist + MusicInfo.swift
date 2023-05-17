//
//  Persist + MusicInfo.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

extension Persist {
    
    // 如果 MusicInfo 表为空，则从 JSON 文件加载数据
    public func loadMusicInfosIfNeeded() {
        do {
            let musicInfos: [MusicInfo] = try database.getObjects(fromTable: "MusicInfo")

            if RPMResources.hasMainBundleResource() && !RPMResources.hasDocumentsResource() {
                try database.delete(fromTable: "MusicInfo")
                if let rpmEntities = RPMResources.loadRPMEntitiesFromMainBundle() {
                    for rpmEntity in rpmEntities {
                        try database.insert(objects: rpmEntity.musicInfo, intoTable: "MusicInfo")
                    }
                }
            } else if musicInfos.count < 10 && RPMResources.hasDocumentsResource() {
                try database.delete(fromTable: "MusicInfo")
                if let rpmEntities = RPMResources.loadRPMEntitiesFromDocuments() {
                    for rpmEntity in rpmEntities {
                        try database.insert(objects: rpmEntity.musicInfo, intoTable: "MusicInfo")
                    }
                }
            } else if musicInfos.isEmpty {
                if let rpmEntities = RPMResources.loadRPMEntitiesFromDocuments() {
                    for rpmEntity in rpmEntities {
                        try database.insert(objects: rpmEntity.musicInfo, intoTable: "MusicInfo")
                    }
                } else if let rpmEntities = RPMResources.loadRPMEntitiesFromMainBundle() {
                    for rpmEntity in rpmEntities {
                        try database.insert(objects: rpmEntity.musicInfo, intoTable: "MusicInfo")
                    }
                }
            }
        } catch {
            print("加载音乐信息错误：\(error)")
        }
    }
}
