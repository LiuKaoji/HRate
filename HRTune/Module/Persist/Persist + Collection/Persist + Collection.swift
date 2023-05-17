//
//  Persist + Collection.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift
import AEAudio

//MARK: - 音频收藏夹
extension Persist {
    
    func loadAllMusicInfos() -> [MusicInfo] {
        var allMusicInfos: [MusicInfo] = []

        do {
            // 直接从数据库获取所有的音乐信息
            allMusicInfos = try database.getObjects(fromTable: "MusicInfo")

            // 对 allMusicInfos 进行排序
            allMusicInfos.sort { (musicInfo1, musicInfo2) -> Bool in
                if musicInfo1.albumName == musicInfo2.albumName {
                    return musicInfo1.serialNumber < musicInfo2.serialNumber
                } else {
                    return musicInfo1.albumName > musicInfo2.albumName
                }
            }

        } catch {
            print("加载音乐信息错误：\(error)")
        }

        return allMusicInfos
    }

    func updateMusicInfo(info: MusicInfo) {
        guard let infoId = info.id else { return }
        
        do {
            try database.update(table: "MusicInfo", on: MusicInfo.CodingKeys.all, with: info, where: MusicInfo.CodingKeys.id == infoId)
        } catch {
            print("更新音频错误：\(error)")
        }
    }
}

//MARK: - 自定义音频包相关
extension Persist {
    
    func fetchAllCollection() -> [AudioPlayable] {
        var collection: [AudioPlayable] = []
        
        do {
            
            let musicInfos: [MusicInfo] = try database.getObjects(fromTable: "MusicInfo", where: MusicInfo.Properties.isFavor == true, orderBy: [MusicInfo.Properties.favorDate.asOrder(by: .descending)])
            collection.append(contentsOf: musicInfos)
            
            let playListData: [AudioEntity] = try database.getObjects(fromTable: "AudioEntity", where: AudioEntity.Properties.isFavor == true, orderBy: [AudioEntity.Properties.favorDate.asOrder(by: .descending)])
            collection.append(contentsOf: playListData)
            
        } catch let error {
            print("Error fetching data: \(error)")
        }
        
        // Sort the entire collection by favorDate
        collection.sort { $0.getFavorDate() > $1.getFavorDate() }
        
        return collection
    }

}
