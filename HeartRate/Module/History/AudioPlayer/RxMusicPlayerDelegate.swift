//
//  RxMusicPlayerDelegate.swift
//  HeartRate
//
//  Created by kaoji on 4/18/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

open class RxMusicPlayerDelegate: DelegateProxy<MusicPlayer, MusicPlayerDelegate>, DelegateProxyType, MusicPlayerDelegate {
    

    // 对象
    public weak private(set) var player: MusicPlayer?

    // 代理转发
    public init(player: ParentObject) {
        self.player = player
        super.init(parentObject: player, delegateProxy: RxMusicPlayerDelegate.self)
    }

    // 注册已知方法
    public static func registerKnownImplementations() {
        self.register { RxMusicPlayerDelegate(player: $0) }
    }

    public static func currentDelegate(for object: MusicPlayer) -> MusicPlayerDelegate? {
        object.delegate
    }

    public static func setCurrentDelegate(_ delegate: MusicPlayerDelegate?, to object: MusicPlayer) {
        object.delegate = delegate
    }
}

extension Reactive where Base: MusicPlayer {
    

    public var delegate: DelegateProxy<MusicPlayer, MusicPlayerDelegate> {
        RxMusicPlayerDelegate.proxy(for: base)
    }
    
    
    /// 尝试连接到IP
    public var currentTime: Observable<TimeInterval> {
        delegate.methodInvoked(#selector(MusicPlayerDelegate.audioPlayer(_:didUpdateCurrentTime:))).map { a in
            try castOrThrow(TimeInterval.self, a[1])
        }
    }
    
    /// 尝试连接到IP
    public var state: Observable<MusicPlayer.State> {
        delegate.methodInvoked(#selector(MusicPlayerDelegate.audioPlayer(_:didChangeState:))).map { a in
            try castOrThrow(MusicPlayer.State.self, a[1])
        }
    }
}
