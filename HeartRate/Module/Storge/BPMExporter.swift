//
//  SRTExporter.swift
//  HRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import Zip

class BPMExporter {
    static var  documentInteractionController: UIDocumentInteractionController?

    static func exportAndShare(audioEntity: AudioEntity, viewController: UIViewController) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        var filesToShare: [URL] = []
        
        // 将JSON加到压缩包
        let jsonString = exportToJSON(audioEntity: audioEntity)
        let jsonFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(audioEntity.name!).json")
        
        do {
            try jsonString?.write(to: jsonFileURL, atomically: true, encoding: .utf8)
            filesToShare.append(jsonFileURL)
        } catch {
            print("Error writing JSON content to file: \(error)")
        }
        
        // 将音频加到压缩包
        let audioURL = documentsDirectory.appendingPathComponent(audioEntity.name!)
        filesToShare.append(audioURL)
        
        if let fileURL = createZipFromFiles(fileURLs: filesToShare, name: "BPMExport - \(audioEntity.name!).zip") {
            shareFilesWithAirDrop(fileURL: fileURL, viewController: viewController)
        } else {
            print("Error creating ZIP file.")
        }
    }
    
    // JSON
    static func exportToJSON(audioEntity: AudioEntity) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(audioEntity)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
        
        return nil
    }
    
    // 创建压缩包进行隔空投送
    private static func createZipFromFiles(fileURLs: [URL], name: String) -> URL? {
        let zipFileName = name
        let fileManager = FileManager.default
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent(zipFileName)
        
        if fileManager.fileExists(atPath: fileURL.path){
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                // Ignore error
            }
        }
        
        do {
            try Zip.zipFiles(paths: fileURLs, zipFilePath: fileURL, password: nil, progress: nil)
            return fileURL
        } catch {
            print("Error zipping files: \(error)")
            return nil
        }
    }
    
    // AirDrop投送
    public static func shareFilesWithAirDrop(fileURL: URL, viewController: UIViewController) {
        documentInteractionController = UIDocumentInteractionController.init(url: fileURL)
        documentInteractionController?.presentOptionsMenu(from: viewController.view.bounds, in: viewController.view, animated: true)
    }
    
}
