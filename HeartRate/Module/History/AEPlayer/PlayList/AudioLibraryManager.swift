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
        let isNotProtectedPredicate2 = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyHasProtectedAsset)
        
        query.addFilterPredicate(isNotProtectedPredicate)
        query.addFilterPredicate(isNotProtectedPredicate2)
        
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
    
    func exportAudio(at url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVURLAsset(url: url)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        
        // 确保可以导出音频
        guard let exportPreset = compatiblePresets.first,
              let exportSession = AVAssetExportSession(asset: asset, presetName: exportPreset) else {
            completion(.failure(NSError(domain: "AudioLibraryManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create export session"])))
            return
        }
        
        // 设置导出选项
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let destinationURL = tempDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        exportSession.outputURL = destinationURL
        // 检查输入资源是否支持.m4a文件类型
          if exportSession.supportedFileTypes.contains(.m4a) {
              exportSession.outputFileType = .m4a
          } else {
              // 使用输入资源的第一个兼容的文件类型
              guard let supportedFileType = exportSession.supportedFileTypes.first else {
                  completion(.failure(NSError(domain: "AudioLibraryManagerError", code: 4, userInfo: [NSLocalizedDescriptionKey: "No supported file types for export"])))
                  return
              }
              exportSession.outputFileType = supportedFileType
          }
        exportSession.shouldOptimizeForNetworkUse = true
        
        // 开始导出
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(.success(destinationURL))
                case .failed, .cancelled:
                    if let error = exportSession.error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "AudioLibraryManagerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Audio export failed or cancelled"])))
                    }
                default:
                    completion(.failure(NSError(domain: "AudioLibraryManagerError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Audio export failed with unknown status"])))
                }
            }
        }
    }
}
