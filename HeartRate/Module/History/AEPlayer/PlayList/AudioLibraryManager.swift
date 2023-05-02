//
//  AudioLibraryManager.swift
//  HRate
//
//  Created by kaoji on 4/27/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioLibraryManager {
    
    static let shared = AudioLibraryManager()
    
    private init() {}
    
    // 请求访问媒体库的权限
    func requestAuthorization(completion: @escaping (MPMediaLibraryAuthorizationStatus) -> Void) {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    func fetchMediaItems() -> [AudioEntity] {
        // 确保已获得授权访问媒体库
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            print("Media library access is not authorized")
            return []
        }
        
        var audioEntities: [AudioEntity] = []
        
        let query = MPMediaQuery.songs()
        let isNotProtectedPredicate = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
        query.addFilterPredicate(isNotProtectedPredicate)
        
        if let items = query.items {
            for item in items {
                if let title = item.title, let url = item.assetURL {
                    let audioEntity = createAudioEntity(from: item)
                    audioEntities.append(audioEntity)
                }
            }
        }
        
        return audioEntities
    }
    
    // 更新后的 createAudioEntity(from:) 方法
    func createAudioEntity(from mediaItem: MPMediaItem) -> AudioEntity {
        let audioEntity = AudioEntity()
        audioEntity.id = Int(mediaItem.persistentID)
        audioEntity.name = mediaItem.title
        audioEntity.ext = mediaItem.assetURL?.pathExtension
        audioEntity.date = formatDate(from: mediaItem.releaseDate)
        audioEntity.duration = formatDuration(from: mediaItem.playbackDuration)
        audioEntity.assetURL = mediaItem.assetURL

        return audioEntity
    }
    
    private func formatDate(from date: Date?) -> String? {
        guard let date = date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    private func formatDuration(from duration: TimeInterval) -> String {
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        let minutes = Int(duration / 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatSize(from size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
