//
//  AudioInfo.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import AVFoundation
import MediaPlayer
import AVFAudio

@objc public class AudioInfo: NSObject {
    @objc public enum URLType: Int {
        case local
        case remote //占位数据
        case iPodMediaLibrary
    }
    
    @objc public var sampleRate: Double = 0
    @objc public var bitRate: Double = 0
    @objc public var channels: Int = 0
    @objc public var urlType: URLType
    @objc public var fileName: String
    @objc public var url: URL
    @objc public var isValid: Bool = false
    @objc public var error: Error?
    @objc public var duration: TimeInterval = 0
    @objc public var fileSize: UInt64 = 0
    @objc public var coverImage: UIImage?


    @objc public init(url: URL) {
        self.url = url
        self.urlType = AudioInfo.determineURLType(from: url)
        self.fileName = AudioInfo.extractFileName(from: url, urlType: urlType)
        super.init()
        getAudioInfo(from: url)
    }
    
    private static func determineURLType(from url: URL) -> URLType {
        if url.isFileURL {
            return .local
        } else if url.scheme == "ipod-library" {
            return .iPodMediaLibrary
        } else {
            return .remote
        }
    }
    

    private func getAudioInfo(from url: URL) {
        
        let fileManager = FileManager.default
        let asset = AVURLAsset(url: url)

        do {
            let audioFile = try AVAudioFile(forReading: url)
            sampleRate = audioFile.fileFormat.sampleRate
            bitRate = audioFile.processingFormat.settings[AVSampleRateConverterAudioQualityKey] as? Double ?? 0
            channels = Int(audioFile.fileFormat.channelCount)
            duration = Double(audioFile.length / Int64(audioFile.fileFormat.sampleRate))
            fileSize = getFileSize(from: url)
            coverImage = getCoverImage(from: asset)
            isValid = true
        } catch {
            print("Error reading audio file: \(error)")
            isValid = false
            self.error = NSError(domain: "AudioInfoError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to load audio track"])
        }
    }

    
    private static func extractFileName(from url: URL, urlType: URLType) -> String {
        switch urlType {
        case .local:
            return url.lastPathComponent
        case .remote:
            if let fileName = url.lastPathComponent.split(separator: "?").first {
                return String(fileName)
            } else {
                return "unknown"
            }
        case .iPodMediaLibrary:
            return extractFileNameFromMediaLibraryURL(url)
        }
    }
    
    ///需要查询媒体库 此方法不通
    private static func extractFileNameFromMediaLibraryURL(_ url: URL) -> String {
        // 创建一个媒体查询，它将返回所有的音乐项目
        let query = MPMediaQuery.songs()
        
        // 检查查询结果中的每一个项目
        for item in query.items ?? [] {
            // 如果项目的 assetURL 与我们正在查找的 URL 匹配，返回项目的标题
            if item.assetURL == url {
                return item.title ?? "未知"
            }
        }
        
        // 如果没有找到匹配的项目，返回 nil
        return "未知"
    }
    
    private func getFileSize(from url: URL) -> UInt64 {
        guard url.scheme != "ipod-library" else { return 0 }

        guard let dict = try? FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary else { return 0 }
        
        return UInt64(dict.fileSize())
    }

    private func getCoverImage(from asset: AVAsset) -> UIImage? {
        let metadata = asset.metadata(forFormat: AVMetadataFormat.id3Metadata)
        for item in metadata {
            if let key = item.commonKey, key.rawValue == "artwork", let imageData = item.dataValue {
                return UIImage(data: imageData)
            }
        }
        return nil
    }

}
