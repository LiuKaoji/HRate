//
//  AudioSession.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import AVFAudio

public extension AVAudioSession{
    static func switchToRecordMode() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Error switching to record mode: \(error.localizedDescription)")
        }
    }


     static func switchToPlaybackMode() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Error switching to playback mode: \(error.localizedDescription)")
        }
    }
    
     static func switchToAmbient() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch let error {
            print("Error switching to ambient mode: \(error.localizedDescription)")
        }
    }
}
