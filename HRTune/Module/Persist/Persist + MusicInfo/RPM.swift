//
//  RPM.swift
//  HRTune
//
//  Created by kaoji on 5/6/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import WCDBSwift
import AEAudio

final class MusicInfo: TableCodable{
    
    var id: Int? // 主键
    var title: String //标题
    var bitRate: Int // 比特率
    var sampleRate: Int // 采样率
    var size: Int //文件大小
    var serialNumber: String // 歌曲序号
    var albumName: String // 所属专辑序号
    var duration: Double//音频总时长
    var isFavor: Bool = false
    var favorDate: TimeInterval = 0
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = MusicInfo
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case title
        case bitRate
        case sampleRate
        case size
        case serialNumber
        case albumName
        case duration
        case isFavor
        case favorDate
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                albumName: ColumnConstraintBinding(isUnique: false),
            ]
        }
    }
    
}


final class RPMEntity: Codable {
    
    var id: Int? // 主键
    var albumName: String = ""
    var musicInfo: [MusicInfo] = [] // 存储 MusicInfo 对象
}


class RPMResources {
    
    static var isSandbox: Bool = false
    
    class func loadRPMEntitiesFromMainBundle() -> [RPMEntity]? {
        guard let rootUrl = mainBundleURL(),
              let url = URL(string: "music_info.json", relativeTo: rootUrl) else {
            return nil
        }
        return loadRPMEntities(from: url)
    }

    class func loadRPMEntitiesFromDocuments() -> [RPMEntity]? {
        guard let rootUrl = documentURL(),
              let url = URL(string: "music_info.json", relativeTo: rootUrl) else {
            return nil
        }
        return loadRPMEntities(from: url)
    }

    private class func loadRPMEntities(from url: URL) -> [RPMEntity]? {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let rpmEntities = try decoder.decode([RPMEntity].self, from: jsonData)
            return rpmEntities
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    public class func hasMainBundleResource() -> Bool {
        let mainBundlePath = Bundle.main.path(forResource: "RPMLite", ofType: "bundle")
        return mainBundlePath != nil && Bundle(path: mainBundlePath!) != nil
    }
    
    public class func hasDocumentsResource() -> Bool {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("RPM.bundle").path
        return documentsUrl != nil && FileManager.default.fileExists(atPath: documentsUrl!)
    }
    
    public class func documentURL() -> URL? {
        if hasDocumentsResource(),
           let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("RPM.bundle").path,
           let documentsBundle = Bundle(path: documentsUrl) {
            isSandbox = true
            return documentsBundle.bundleURL
        }
        return nil
    }
    
    public class func mainBundleURL() -> URL? {
        if hasMainBundleResource(),
           let mainBundlePath = Bundle.main.path(forResource: "RPMLite", ofType: "bundle"),
           let mainBundle = Bundle(path: mainBundlePath) {
            isSandbox = false
            return mainBundle.bundleURL
        }
        return nil
    }
    
    public class func rootURL() -> URL? {
        return documentURL() ?? mainBundleURL()
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
            HRToast(message: "文件不存在", type: .error)
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
    public func isMarkFavor()-> Bool { self.isFavorItem() } // 取消收藏
    
    public func favor() -> MusicInfo {
        let newInfo = self
        newInfo.isFavor = true
        newInfo.favorDate = Date().timeIntervalSince1970
        Persist.shared.updateMusicInfo(info: newInfo)
        return newInfo
    }
    
    public func unfavor() -> MusicInfo {
        let newInfo = self
        newInfo.isFavor = false
        newInfo.favorDate = 0.0
        Persist.shared.updateMusicInfo(info: newInfo)
        return newInfo
    }
    
    public func isFavorItem() -> Bool {
        let newInfo = self
        return newInfo.isFavor
    }
    
    func getFavorDate() -> TimeInterval {
        return favorDate
    }
}
