//
//  RxAudioRecordable.swift
//  AEAudio
//
//  Created by kaoji on 5/4/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio

open class RxAudioRecorderDelegate: DelegateProxy<AudioRecorder, AudioRecordable>, DelegateProxyType, AudioRecordable {

    // 对象
    public weak private(set) var player: AudioRecorder?

    // 代理转发
    public init(player: ParentObject) {
        self.player = player
        super.init(parentObject: player, delegateProxy: RxAudioRecorderDelegate.self)
    }

    // 注册已知方法
    public static func registerKnownImplementations() {
        self.register { RxAudioRecorderDelegate(player: $0) }
    }

    public static func currentDelegate(for object: AudioRecorder) -> AudioRecordable? {
        object.delegate
    }

    public static func setCurrentDelegate(_ delegate: AudioRecordable?, to object: AudioRecorder) {
        object.delegate = delegate
    }
}

extension Reactive where Base: AudioRecorder {
    
    public var delegate: DelegateProxy<AudioRecorder, AudioRecordable> {
        RxAudioRecorderDelegate.proxy(for: base)
    }
    
    /// 当前录制状态
    public var status: Observable<AudioRecordStatus> {
        delegate.methodInvoked(#selector(AudioRecordable.audioRecorder(_:didChangedStatus:))).map { a in
            try castOrThrow(AudioRecordStatus.self, a[1])
        }
        
    }
    
    // 录制完成
    public var finish: Observable<(URL, TimeInterval, Int64)> {
        delegate.methodInvoked(#selector(AudioRecordable.audioRecorder(_:didFinishedWithUrl:duration:fileSize:))).map { a in
            let url = try castOrThrow(URL.self, a[1])
            let duration = try castOrThrow(TimeInterval.self, a[2])
            let fileSize = try castOrThrow(Int64.self, a[3])
            return (url, duration, fileSize)
        }
    }


    /// 录制时间
    public var currentTime: Observable<TimeInterval> {
        delegate.methodInvoked(#selector(AudioRecordable.audioRecorder(_:didUpdateCurrentTime:))).map { a in
            try castOrThrow(TimeInterval.self, a[1])
        }
    }
    
    /// 播放状态
    public var denied: Observable<Void> {
        delegate.methodInvoked(#selector(AudioRecordable.audioRecorderPermissionDenied(_:))).map { _ in
            return
        }
    }
}
