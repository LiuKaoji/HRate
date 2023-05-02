//
//  AudioInfo.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import AVFoundation
import MediaPlayer

@objc public class AudioInfo: NSObject {
    @objc public enum URLType: Int {
        case local
        case remote
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
        let asset = AVURLAsset(url: url)
        
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            sampleRate = Double(audioTrack.naturalTimeScale)
            bitRate = Double(audioTrack.estimatedDataRate)
            channels = audioTrack.formatDescriptions.compactMap { (formatDescription) -> Int? in
                let format = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription as! CMAudioFormatDescription)
                return Int(format?.pointee.mChannelsPerFrame ?? 0)
            }.first ?? 0
            isValid = true
        } else {
            isValid = false
            error = NSError(domain: "AudioInfoError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to load audio track"])
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
        let asset = AVURLAsset(url: url)
        let fileName = asset.url.lastPathComponent
        return fileName
    }
}
