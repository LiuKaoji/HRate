//
//  SRTExporter.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import Zip

class BPMExporter {
    static var activityViewController: UIActivityViewController?
    
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
        
        if let zipFileURL = createZipFromFiles(fileURLs: filesToShare, name: "BPMExport - \(audioEntity.name!).zip") {
            shareFilesWithAirDrop(zipFileURL: zipFileURL, viewController: viewController)
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
        let zipFileURL = tempDirectoryURL.appendingPathComponent(zipFileName)
        
        if fileManager.fileExists(atPath: zipFileURL.path){
            do {
                try fileManager.removeItem(at: zipFileURL)
            } catch {
                // Ignore error
            }
        }
        
        do {
            try Zip.zipFiles(paths: fileURLs, zipFilePath: zipFileURL, password: nil, progress: nil)
            return zipFileURL
        } catch {
            print("Error zipping files: \(error)")
            return nil
        }
    }
    
    // AirDrop投送
    private static func shareFilesWithAirDrop(zipFileURL: URL, viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [zipFileURL], applicationActivities: nil)
        BPMExporter.activityViewController = activityViewController
        activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .openInIBooks, .markupAsPDF]
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}
