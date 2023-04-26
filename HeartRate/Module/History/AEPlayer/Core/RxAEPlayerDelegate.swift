//
//  RxAEPlayerDelegate.swift
//  HRate
//
//  Created by kaoji on 4/26/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

open class RxAEPlayerDelegate: DelegateProxy<AEPlayer, AudioPlayable>, DelegateProxyType, AudioPlayable {
    

    // 对象
    public weak private(set) var player: AEPlayer?

    // 代理转发
    public init(player: ParentObject) {
        self.player = player
        super.init(parentObject: player, delegateProxy: RxAEPlayerDelegate.self)
    }

    // 注册已知方法
    public static func registerKnownImplementations() {
        self.register { RxAEPlayerDelegate(player: $0) }
    }

    public static func currentDelegate(for object: AEPlayer) -> AudioPlayable? {
        object.delegate
    }

    public static func setCurrentDelegate(_ delegate: AudioPlayable?, to object: AEPlayer) {
        object.delegate = delegate
    }
}

extension Reactive where Base: AEPlayer {
    

    public var delegate: DelegateProxy<AEPlayer, AudioPlayable> {
        RxAEPlayerDelegate.proxy(for: base)
    }
    
    
    /// 当前播放时间
    public var currentTime: Observable<TimeInterval> {
        delegate.methodInvoked(#selector(AudioPlayable.player(_:didUpdateCurrentTime:))).map { a in
            try castOrThrow(TimeInterval.self, a[1])
        }
    }
    
    // 总时长
    public var totalTime: Observable<TimeInterval> {
        delegate.methodInvoked(#selector(AudioPlayable.player(_:didUpdateTotalTime:))).map { a in
            try castOrThrow(TimeInterval.self, a[1])
        }
    }


    /// 播放状态
    public var state: Observable<AEPlayerStatus> {
        delegate.methodInvoked(#selector(AudioPlayable.player(_:didChangedStatus:))).map { a in
            let rawValue = try castOrThrow(NSNumber.self, a[1])
            guard let state = AEPlayerStatus(rawValue: Int(truncating: rawValue)) else {
                throw RxCocoaError.castingError(object: a[1], targetType: AEPlayerStatus.self)
            }
            return state
        }
    }
    
    /// 播放状态
    public var frequencyData: Observable<[Float]> {
        delegate.methodInvoked(#selector(AudioPlayable.player(_:didUpdatefrequencyData:))).map { a in
            let value = try castOrThrow([Float].self, a[1])
            return value
        }
    }
    
    /// 播放状态
    public var info: Observable<String> {
        delegate.methodInvoked(#selector(AudioPlayable.player(_:didUpdateAudioFileInfo:))).map { a in
            let value = try castOrThrow(String.self, a[1])
            return value
        }
    }

}
