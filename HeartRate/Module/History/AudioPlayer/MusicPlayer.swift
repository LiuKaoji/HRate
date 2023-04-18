//
//  MusicPlayer.swift
//  HeartRate
//
//  Created by kaoji on 4/18/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AVFoundation

@objc public protocol MusicPlayerDelegate: AnyObject {
    @objc optional func audioPlayer(_ player: MusicPlayer, didUpdateCurrentTime currentTime: TimeInterval)
    @objc optional func audioPlayer(_ player: MusicPlayer, didChangeState state: MusicPlayer.State)
}

@objc open class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    
    @objc public enum State: Int {
        case playing = 0, paused, stopped, error
    }
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    public weak var delegate: MusicPlayerDelegate?
    
    public var state: State = .stopped {
        didSet {
            delegate?.audioPlayer?(self, didChangeState: state)
        }
    }
    
    public func play(url: URL) {
        self.stop()
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            
            startTimer()
            state = .playing
        } catch {
            print("Error initializing AVAudioPlayer: \(error)")
            state = .error
        }
    }
    
    public func pause() {
        player?.pause()
        stopTimer()
        state = .paused
    }
    
    public func resume() {
        player?.play()
        startTimer()
        state = .playing
    }
    
    public func stop() {
        player?.stop()
        player = nil
        stopTimer()
        state = .stopped
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let currentTime = self.player?.currentTime ?? 0
            self.delegate?.audioPlayer?(self, didUpdateCurrentTime: currentTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        state = .stopped
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        state = .error
    }
}
