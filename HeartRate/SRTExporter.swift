//
//  SRTExporter.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation

class SRTExporter {
    
    // Exports an SRT file containing the BPM values for the specified AudioEntity
    static func exportSRTFile(forAudio audio: AudioEntity, withBPMs bpmEntities: [BPMEntity], returnURL: Bool = true) -> Any? {
        let srtURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(audio.name!).srt")
        var srtContent = ""
        var subtitleIndex = 1
        
        var bpmValues: [Double] = []
        for bpmEntity in bpmEntities {
            bpmValues.append(Double(bpmEntity.bpm))
            
            let nowBPM = bpmValues.last ?? 0
            let minBPM = bpmValues.min() ?? 0
            let maxBPM = bpmValues.max() ?? 0
            let avgBPM = bpmValues.reduce(0, +) / Double(bpmValues.count)
            
            let nowSubtitle = "\(subtitleIndex) NOW: \(String(format: "%.0f", nowBPM)) BPM    "
            let minSubtitle = "\(subtitleIndex + 1) MIN: \(String(format: "%.0f", minBPM)) BPM    "
            let maxSubtitle = "\(subtitleIndex + 2) MAX: \(String(format: "%.0f", maxBPM)) BPM    "
            let avgSubtitle = "\(subtitleIndex + 3) AVG: \(String(format: "%.0f", avgBPM)) BPM    "
            
            srtContent += nowSubtitle + minSubtitle + maxSubtitle + avgSubtitle
            
            subtitleIndex += 4
        }
        
        if returnURL {
            do {
                try srtContent.write(to: srtURL, atomically: true, encoding: .utf8)
                return srtURL
            } catch {
                print("Error writing SRT content to file: \(error)")
                return nil
            }
        } else {
            return srtContent
        }
    }
}
