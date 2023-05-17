//
//  Persist + AudioEntity.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

//MARK: -录音相关
extension Persist{
    
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
            try database.update(table: "AudioEntity", on: AudioEntity.CodingKeys.all, with: audioEntity, where: AudioEntity.CodingKeys.id == audioId)
        } catch {
            print("更新音频错误：\(error)")
        }
    }

}
