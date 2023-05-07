//
//  RxWCSessionDelegate.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import WatchConnectivity
import RxSwift

class RxWCSessionDelegate: NSObject, WCSessionDelegate {
    public var activationDidComplete: Observable<(WCSessionActivationState, Error?)> {
        return activationDidCompleteSubject.asObservable()
    }

    #if os(iOS)
    public var sessionDidBecomeInactive: Observable<WCSession> {
        return sessionDidBecomeInactiveSubject.asObservable()
    }

    public var sessionDidDeactivate: Observable<WCSession> {
        return sessionDidDeactivateSubject.asObservable()
    }
    #endif

    public var sessionReachabilityDidChange: Observable<WCSession> {
        return sessionReachabilityDidChangeSubject.asObservable()
    }
    
    public var didReceiveMessage: Observable<[String: Any]> {
        return didReceiveMessageSubject.asObservable()
    }
    
    public var didReceiveMessageWithReplyHandler: Observable<([String: Any], ([String : Any]) -> Void)> {
        return didReceiveMessageWithReplyHandlerSubject.asObservable()
    }

    public var didReceiveMessageData: Observable<Data> {
        return didReceiveMessageDataSubject.asObservable()
    }

    public var didReceiveMessageDataWithReplyHandler: Observable<(Data, (Data) -> Void)> {
        return didReceiveMessageDataWithReplyHandlerSubject.asObservable()
    }
    
    public var didReceiveApplicationContext: Observable<[String: Any]> {
        return didReceiveApplicationContextSubject.asObservable()
    }
    
    public var didFinishWithUserInfoTransfer: Observable<(WCSessionUserInfoTransfer, Error?)> {
        return didFinishWithUserInfoTransferSubject.asObservable()
    }

    public var didFinishFileTransfer: Observable<(WCSessionFileTransfer, Error?)> {
        return didFinishFileTransferSubject.asObservable()
    }

    public var didReceiveFile: Observable<WCSessionFile> {
        return didReceiveFileSubject.asObservable()
    }
    
    private let activationDidCompleteSubject = PublishSubject<(WCSessionActivationState, Error?)>()

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        activationDidCompleteSubject.onNext((activationState, error))
    }
    
    private let sessionReachabilityDidChangeSubject = PublishSubject<WCSession>()
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        sessionReachabilityDidChangeSubject.onNext(session)
    }
    
    private let didReceiveMessageSubject = PublishSubject<[String: Any]>()

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        didReceiveMessageSubject.onNext(message)
    }
    
    private let didReceiveMessageWithReplyHandlerSubject = PublishSubject<([String: Any], ([String : Any]) -> Void)>()

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        didReceiveMessageWithReplyHandlerSubject.onNext((message, replyHandler))
    }

    private let didReceiveMessageDataSubject = PublishSubject<Data>()

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        didReceiveMessageDataSubject.onNext(messageData)
    }

    private let didReceiveMessageDataWithReplyHandlerSubject = PublishSubject<(Data, (Data) -> Void)>()
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        didReceiveMessageDataWithReplyHandlerSubject.onNext((messageData, replyHandler))
    }

    private let didReceiveApplicationContextSubject = PublishSubject<[String: Any]>()
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        didReceiveApplicationContextSubject.onNext(applicationContext)
    }
    
    private let didFinishWithUserInfoTransferSubject = PublishSubject<(WCSessionUserInfoTransfer, Error?)>()
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        didFinishWithUserInfoTransferSubject.onNext((userInfoTransfer, error))
    }

    private let didReceiveUserInfoSubject = PublishSubject<[String: Any]>()

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        didReceiveUserInfoSubject.onNext(userInfo)
    }

    private let didFinishFileTransferSubject = PublishSubject<(WCSessionFileTransfer, Error?)>()
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        didFinishFileTransferSubject.onNext((fileTransfer, error))
    }

    private let didReceiveFileSubject = PublishSubject<WCSessionFile>()
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        didReceiveFileSubject.onNext(file)
    }
    
    private let sessionDidBecomeInactiveSubject = PublishSubject<WCSession>()

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        sessionDidBecomeInactiveSubject.onNext(session)
    }
    
    private let sessionDidDeactivateSubject = PublishSubject<WCSession>()
    
    func sessionDidDeactivate(_ session: WCSession) {
        sessionDidDeactivateSubject.onNext(session)
    }
    #endif
}
