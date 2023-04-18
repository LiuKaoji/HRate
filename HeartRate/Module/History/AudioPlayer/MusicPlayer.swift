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

@objc open class MusicPlayer: NSObject {
    
    @objc public enum State: Int {
        case playing = 0, paused, stopped, error
    }
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    public weak var delegate: MusicPlayerDelegate?
    
    public var state: State = .stopped {
        didSet {
            delegate?.audioPlayer?(self, didChangeState: state)
        }
    }
    
    public func play(url: URL) {
        self.stop()
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        addPeriodicTimeObserver()
        
        state = .playing
    }
    
    public func pause() {
        player?.pause()
        state = .paused
    }
    
    public func resume() {
        player?.play()
        state = .playing
    }
    
    public func stop() {
        player?.pause()
        player = nil
        removePeriodicTimeObserver()
        
        state = .stopped
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTimeMake(value: 1, timescale: 1)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            self.delegate?.audioPlayer?(self, didUpdateCurrentTime: currentTime)
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}

