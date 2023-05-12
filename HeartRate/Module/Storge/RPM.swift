//
//  RPM.swift
//  HRate
//
//  Created by kaoji on 5/6/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import WCDBSwift
import AEAudio

public struct MusicInfo: Codable {
    
    let title: String //标题
    let bitRate: Int // 比特率
    let sampleRate: Int // 采样率
    let size: Int //文件大小
    let serialNumber: String // 歌曲序号
    let albumName: String // 所属专辑序号
    let duration: Double//音频总时长
    var isFavor: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case bitRate = "bitRate"
        case sampleRate = "sampleRate"
        case size = "size"
        case serialNumber = "serialNumber"
        case albumName = "albumName"
        case duration = "duration"
    }
}


final class RPMEntity: TableCodable {
    
    var id: Int? // 主键
    var albumName: String = ""
    var musicInfo: [MusicInfo] = [] // 存储 MusicInfo 对象
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = RPMEntity
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case albumName
        case musicInfo
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                albumName: ColumnConstraintBinding(isUnique: true),
            ]
        }
    }
}


class RPMResources {
    
    class func loadRPMEntities() -> [RPMEntity]? {
        guard let rootUrl = rootURL(),
              let url = URL(string: "music_info.json", relativeTo: rootUrl) else {
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            var rpmEntities = try decoder.decode([RPMEntity].self, from: jsonData)
            
            // 新到旧排序
            rpmEntities.sort { entity1, entity2 in
                guard let albumName1 = Int(entity1.albumName), let albumName2 = Int(entity2.albumName) else {
                    return false
                }
                return albumName1 < albumName2
            }
            
            // 新到旧排序
            rpmEntities = rpmEntities.map { entity in
                var newEntity = entity
                newEntity.musicInfo = entity.musicInfo.map { musicInfo in
                    MusicInfo(title: musicInfo.title, bitRate: musicInfo.bitRate, sampleRate: musicInfo.sampleRate, size: musicInfo.size, serialNumber: musicInfo.serialNumber, albumName: musicInfo.albumName, duration: musicInfo.duration)
                }
                return newEntity
            }
            
            return rpmEntities
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    public class func rootURL() -> URL? {
        let mainBundlePath = Bundle.main.path(forResource: "RPM", ofType: "bundle")
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("RPM.bundle").path
        
        if let mainBundlePath = mainBundlePath,
           let mainBundle = Bundle(path: mainBundlePath) {
            return mainBundle.bundleURL
        } else if let documentsUrl = documentsUrl,
                  FileManager.default.fileExists(atPath: documentsUrl),
                  let documentsBundle = Bundle(path: documentsUrl) {
            return documentsBundle.bundleURL
        }
        
        return nil
    }
}

extension MusicInfo: AudioPlayable{
    
    
    public func audioName() -> String {
        albumName + "-" + title
    }
    
    public func audioDuration() -> String {
        TimeFormat.formatTimeInterval(seconds: duration)
    }
    
    public func audioDurationText() -> String {
        return TimeFormat.formatTimeInterval(seconds: duration)
    }
    
    public func audioDuration() -> Double {
        return duration
    }
    
    public func audioURL() -> URL? {
        if let rootURL = RPMResources.rootURL() {
            let fileURL = rootURL.appendingPathComponent("\(albumName)/\(title)")
            if FileManager.default.fileExists(atPath: fileURL.path){
                return fileURL
            }
            return nil
        }
        return nil
    }
    
    public func audioSize() -> String {
        toByteString(UInt64(size))
    }
    
    public func remove(){}
    
    public func markFavor() { let _ = favor() }// 标记收藏
    public func unMarkFavor() { let _ = unfavor() } // 取消收藏
    
    public func favor() -> MusicInfo {
        var newInfo = self
        newInfo.isFavor = true
        return newInfo
    }

    public func unfavor() -> MusicInfo {
        var newInfo = self
        newInfo.isFavor = false
        return newInfo
    }
}
