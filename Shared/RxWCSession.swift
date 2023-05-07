//
//  RxWCSession.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import WatchConnectivity
import RxSwift

// 定义一些 Watch Connectivity 会话可能出现的错误类型
public enum RxWCSessionError: Error {
    case watchAppIsNotInstalled  // Apple Watch 应用未安装
    case sessionIsNotActivated   // 会话未激活
    case counterpartAppIsNotReachable  // 对应的应用无法访问
    case unsupported  // 不支持的功能
}

public class RxWCSession {
    // 会话状态

    // 当会话的激活状态发生改变时发出通知。在订阅时，它会发出当前的状态。
    public var activationState: Observable<WCSessionActivationState> {
        return .deferred { [delegate, session] in
            return delegate.activationDidComplete
                .map { $0.0 }
                .startWith(session.activationState)
        }
    }

    // 当会话的可达状态发生改变时发出通知。在订阅时，它会发出当前的状态。
    public var isReachable: Observable<Bool> {
        return .deferred { [delegate, session] in
            return delegate.sessionReachabilityDidChange
                .map { $0.isReachable }
                .startWith(session.isReachable)
        }
    }

    // 当待传输文件数组的值发生变化时发出通知。在订阅时，它会发出当前的状态。
    public var outstandingFileTransfers: Observable<[WCSessionFileTransfer]> {
        return .deferred { [delegate, session] in
            return delegate.didFinishFileTransfer
                .map { [session] _ in session.outstandingFileTransfers }
                .startWith(session.outstandingFileTransfers)
        }
    }
    
    // 接收数据

    // 当接收到无需回复处理器的消息时发出通知。
    public var didReceiveMessage: Observable<[String: Any]> {
        return delegate.didReceiveMessage
    }

    // 当接收到需要回复处理器的消息时发出通知。
    // 发出的值是一个包含接收到的消息和回复回调的元组。
    public var didReceiveMessageWithReplyHandler: Observable<([String: Any], ([String : Any]) -> Void)> {
        return delegate.didReceiveMessageWithReplyHandler
    }

    // 当接收到无需回复处理器的数据消息时发出通知。
    public var didReceiveMessageData: Observable<Data> {
        return delegate.didReceiveMessageData
    }

    // 当接收到需要回复处理器的数据消息时发出通知。
    // 发出的值是一个包含接收到的数据消息和回复回调的元组。
    public var didReceiveMessageDataWithReplyHandler: Observable<(Data, (Data) -> Void)> {
        return delegate.didReceiveMessageDataWithReplyHandler
    }

    private let session: WCSession
    private let delegate: RxWCSessionDelegate

    // 构造器
    public init(session: WCSession = WCSession.default) {
        self.session = session
        self.delegate = RxWCSessionDelegate()

        session.delegate = delegate
    }

    // 激活会话
    public func activate() -> Completable {
        return Completable.deferred { [delegate] in
            // 检查当前设备是否支持会话
            guard WCSession.isSupported() else {
                throw RxWCSessionError.unsupported
            }

            return delegate.activationDidComplete
                .map { state, error in
                    // 如果有错误，抛出错误
                    if let error = error {
                        throw error
                    }

                    // 确保会话已经激活
                    return state == .activated
                }
                // 只取激活状态的事件
                .filter { $0 == true }
                .take(1)
                .ignoreElements()
                .asCompletable()
        }
        .do(onSubscribed: { [session] in
            // 订阅后激活会话
            session.activate()
        })
    }

    // 发送消息并等待回复
    public func sendMessage(_ message: [String: Any], waitForSession: Bool = true) -> Single<[String: Any]> {
        let sendMessage = Single<[String: Any]>.create { [session] observer in
            session.sendMessage(message, replyHandler: { message in
                observer(.success(message))
            }, errorHandler: { error in
                observer(.failure(error))
            })

            return Disposables.create()
        }

        return isAbleToSendData(waitForSession: true)
            .flatMap { _ in
                sendMessage
            }
    }

    // 发送消息但不需要回复
    public func sendMessageWithoutReply(_ message: [String: Any], waitForSession: Bool = true) -> Completable {
        let sendMessage = Completable.create { [session] observer in
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                observer(.error(error))
            })

            return Disposables.create()
        }

        return isAbleToSendData(waitForSession: true)
            .asObservable()
            .flatMap { _ in
                sendMessage
            }
            .ignoreElements()
            .asCompletable()
    }

    // 发送数据消息并等待回复
    public func send(messageData: Data, waitForSession: Bool = true) -> Single<Data> {
        let sendMessageData = Single<Data>.create { [session] observer in
            session.sendMessageData(messageData, replyHandler: { data in
                observer(.success(data))
            }, errorHandler: { error in
                observer(.failure(error))
            })

            return Disposables.create()
        }

        return isAbleToSendData(waitForSession: true)
            .flatMap { _ in
                sendMessageData
            }
    }

    // 发送数据消息但不需要回复
    public func sendWithoutReply(messageData: Data, waitForSession: Bool = true) -> Completable {
        let sendMessageData = Completable.create { [session] observer in
            session.sendMessageData(messageData, replyHandler: nil, errorHandler: { error in
                observer(.error(error))
            })

            return Disposables.create()
        }

        return isAbleToSendData(waitForSession: true)
            .asObservable()
            .flatMap { _ in
                sendMessageData
            }
            .ignoreElements()
            .asCompletable()
    }

    // 发送文件
    public func transferFile(_ file: URL, metadata: [String : Any]?) -> Observable<Progress> {
        return .create { [session, delegate] observer in
            let fileTransfer = session.transferFile(file, metadata: metadata)
            let compositeDisposable = CompositeDisposable()

            observer.onNext(fileTransfer.progress)

            let monitorFileTransfersDispsoable = delegate.didFinishFileTransfer
                .subscribe(onNext: { transfer, error in
                    // 只关注当前的文件传输
                    guard transfer == fileTransfer else {
                        return
                    }

                    if let error = error {
                        observer.onError(error)
                    }

                    observer.onCompleted()
                })

            let fileTransferDisposable = Disposables.create {
                // 如果订阅被取消，取消文件传输
                fileTransfer.cancel()
            }
            
            _ = compositeDisposable.insert(monitorFileTransfersDispsoable)
            _ = compositeDisposable.insert(fileTransferDisposable)

            return compositeDisposable
        }
    }

    // 发送用户信息
    public func transferUserInfo(_ userInfo: [String : Any] = [:]) -> Completable {
        return .create { [session, delegate] observer in
            let userInfoTransfer = session.transferUserInfo(userInfo)
            let compositeDisposable = CompositeDisposable()

            let monitorFileTransfersDispsoable = delegate.didFinishWithUserInfoTransfer
                .subscribe(onNext: { transfer, error in
                    // 只关注当前的用户信息传输
                    guard transfer == userInfoTransfer else {
                        return
                    }

                    if let error = error {
                        observer(.error(error))
                    }

                    observer(.completed)
                })

            let fileTransferDisposable = Disposables.create {
                // 如果订阅被取消，取消用户信息传输
                userInfoTransfer.cancel()
            }

            _ = compositeDisposable.insert(monitorFileTransfersDispsoable)
            _ = compositeDisposable.insert(fileTransferDisposable)

            return compositeDisposable
        }
    }
}

private extension RxWCSession {
    func isAbleToSendData(waitForSession: Bool) -> Single<Bool> {
        return .deferred { [session, activationState, isReachable] in
            // 如果不需要等待会话，直接检查会话状态
            guard waitForSession else {
                switch (session.activationState, session.isReachable) {
                case (.activated, true):
                    return .just(true)
                case (.activated, false):
                    throw RxWCSessionError.counterpartAppIsNotReachable
                case (.inactive, _),
                     (.notActivated, _),
                     (_, _):
                    throw RxWCSessionError.sessionIsNotActivated
                }
            }

            return activationState.filter { $0 == .activated }
                .flatMapLatest { [isReachable] _ in return isReachable }
                .filter {  $0 == true }
                .take(1)
                .asSingle()
            }
    }

    #if os(iOS)
    // 检查是否安装了手表应用
    func checkAppIsInstalled() throws {
        guard session.isWatchAppInstalled else {
            throw RxWCSessionError.watchAppIsNotInstalled
        }
    }
    #endif
}

