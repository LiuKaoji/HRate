//
//  RxAudioPlayerDelegate.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio

open class RxAudioPlayerDelegate: DelegateProxy<AudioPlayer, AudioPlayerDelegate>, DelegateProxyType, AudioPlayerDelegate {

    // 对象
    public weak private(set) var player: AudioPlayer?

    // 代理转发
    public init(player: ParentObject) {
        self.player = player
        super.init(parentObject: player, delegateProxy: RxAudioPlayerDelegate.self)
    }

    // 注册已知方法
    public static func registerKnownImplementations() {
        self.register { RxAudioPlayerDelegate(player: $0) }
    }

    public static func currentDelegate(for object: AudioPlayer) -> AudioPlayerDelegate? {
        object.delegate
    }

    public static func setCurrentDelegate(_ delegate: AudioPlayerDelegate?, to object: AudioPlayer) {
        object.delegate = delegate
    }
}

extension Reactive where Base: AudioPlayer {
    

    public var delegate: DelegateProxy<AudioPlayer, AudioPlayerDelegate> {
        RxAudioPlayerDelegate.proxy(for: base)
    }
    
    
    /// 当前播放时间
    public var currentTime: Observable<TimeInterval> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.player(_:didUpdateTime:))).map { a in
            try castOrThrow(TimeInterval.self, a[1])
        }
    }
    
    // 总时长
    public var totalTime: Observable<TimeInterval> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.player(_:didUpdateDuration:))).map { a in
            try castOrThrow(TimeInterval.self, a[1])
        }
    }


    /// 播放状态
    public var state: Observable<AudioPlayerStatus> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.player(_:didChangeStatus:))).map { a in
            let rawValue = try castOrThrow(NSNumber.self, a[1])
            guard let state = AudioPlayerStatus(rawValue: Int(truncating: rawValue)) else {
                throw RxCocoaError.castingError(object: a[1], targetType: AudioPlayerStatus.self)
            }
            return state
        }
    }
    
    /// 播放状态
    public var frequencyData: Observable<[[Float]]> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.player(_:didUpdateFrequencyData:))).map { a in
            let value = try castOrThrow([[Float]].self, a[1])
            return value
        }
    }

    public var fail: Observable<AudioPlayerError> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.player(_:didFailWithError:))).map { a in
            let value = try castOrThrow(AudioPlayerError.self, a[1])
            return value
        }
    }
    
    public var next: Observable<Void> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.playerDidHandleNext)).map { a in
            return
        }
    }
    
    public var previous: Observable<Void> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.playerDidHandlePrevious)).map { a in
            return
        }
    }
    
    public var coverImage: Observable<UIImage> {
        delegate.methodInvoked(#selector(AudioPlayerDelegate.player(_:didUpdateCoverImage:))).map { a in
            let value = try castOrThrow(UIImage.self, a[1])
            return value
        }
    }
    
}
