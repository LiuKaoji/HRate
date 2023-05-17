//
//  WatchConnector.swift
//  HRTune
//
//  Created by kaoji on 01/25/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchConnectivity

/// iPhone 和 Apple Watch 之间的通信管理器。
open class WatchConnector: NSObject, WCSessionDelegate {
    
    // MARK: - 初始化
    
#if os(iOS)
    /// 一个共享的单例。如果当前设备不支持 Watch Connectivity 框架，则返回 nil。
    public static var shared: WatchConnector? {
        if WCSession.isSupported() {
            return WatchConnector.sharedInstance
        }
        return nil
    }
    
    // 是否有配对的设备
    public var isPaired: Bool {
        return defaultSession.isPaired
    }
    
    // 当前配对设备是否可达
    public var isReachable: Bool {
        return defaultSession.isReachable
    }

    // 是否安装watchApp
    public var isWatchAppInstalled: Bool {
        return defaultSession.isWatchAppInstalled
    }

#elseif os(watchOS)
    /// 一个共享的单例。
    static var shared: WatchConnector {
        // 在 watchOS 上，Watch Connectivity 框架始终受支持。
        return WatchConnector.sharedInstance
    }
#endif
    
    /// 单例。
    private static let sharedInstance = WatchConnector()
    
    private override init() {
        super.init()
    }
    
    
    // MARK: - 属性
    
    private var defaultSession: WCSession {
        return WCSession.default
    }
    
    /// 用于响应来自配对设备的消息和传输的用户信息的处理程序句柄。
    ///
    /// 每个处理程序都承诺从主队列调用。
    private var messageHandlers = [MessageHandler]()
    
    /// 在主队列中调用。
    private var sessionActivationCompletionHandlers = [((WCSession) -> Void)]()
    
    

    
    // MARK: - 函数
    
    /// 添加用于响应来自配对设备的消息和传输的用户信息的处理程序句柄。
    ///
    /// 处理程序承诺从主队列调用。
    public func addMessageHandler(_ messageHandler: MessageHandler) {
        guard !messageHandlers.contains(messageHandler) else{
            return
        }
        messageHandlers.append(messageHandler)
    }
    
    /// 从列表中移除处理程序句柄。
    public func removeMessageHandler(_ messageHandler: MessageHandler) {
        if let index = messageHandlers.firstIndex(of: messageHandler) {
            messageHandlers.remove(at: index)
        }
    }
    
    /// 异步激活 wcSession。
    public func activate() {
        defaultSession.delegate = self
        defaultSession.activate()
    }
    
    /// 获取已激活的 WCSession。如果当前会话尚未激活，则会先激活它。
    ///
    /// - parameter handler: 如果当前设备不支持 Watch Connectivity，则返回 nil。将从主队列中调用。
    public func fetchActivatedSession(handler: @escaping (WCSession) -> Void, error: (() -> Void)? = nil) {
        
        activate()
        
        if defaultSession.activationState == .activated {
            handler(defaultSession)
        } else {
            sessionActivationCompletionHandlers.append(handler)
            error?()
        }
    }
    
    /// 获取会话是否可达。
    public func fetchReachableState(handler: @escaping (Bool) -> Void) {
        fetchActivatedSession { session in
            handler(session.isReachable)
        }
    }
    
    /// 向配对设备发送消息。如果配对设备不可达，则不会发送该消息。
    public func send(_ message: [MessageKey : Any]) {
        fetchActivatedSession { session in
            session.sendMessage(self.sessionMessage(for: message), replyHandler: nil)
        }
    }
    
    /// 向配对设备发送消息。如果配对设备不可达，则不会发送该消息。
    ///
    /// - parameter message: 要发送的消息
    /// - parameter replyHandler: 成功发送消息后的处理程序。将从主队列调用。
    /// - parameter errorHandler: 发送消息失败时的处理程序。将从主队列调用。
    public func sendWithReply(_ message: [MessageKey: Any], replyHandler: (() -> Void)?, errorHandler: ((String) -> Void)?) {
        fetchActivatedSession { session in
            guard session.isReachable else {
                if let errorHandler = errorHandler {
                    DispatchQueue.main.async {
                        errorHandler(WCErrorParser.parseError(WCError.notReachable))
                    }
                }
                return
            }
            session.sendMessage(self.sessionMessage(for: message), replyHandler: nil)
            replyHandler?()
        }
    }

    
    /// 传输消息到配对设备。
    public func transfer(_ message: [MessageKey : Any]) {
        fetchActivatedSession { session in
            session.transferUserInfo(self.sessionMessage(for: message))
        }
    }
    
    fileprivate func sessionMessage(for message: [MessageKey : Any]) -> [String : Any] {
        var sessionMessage = [String : Any]()
        message.forEach { sessionMessage[$0.key.rawValue] = $0.value }
        return sessionMessage
    }
    
    private func handle(_ receivedMessage: [String : Any]) {
        
        var convertedMessage = [MessageKey: Any]()
        receivedMessage.forEach { convertedMessage[MessageKey($0.key)] = $0.value }
        
        DispatchQueue.main.async {
            self.messageHandlers.forEach { $0.handler(convertedMessage) }
        }
    }
    
    
    // MARK: - WCSessionDelegate
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
        
        if activationState == .activated {
            DispatchQueue.main.async {
                self.sessionActivationCompletionHandlers.forEach { $0(session) }
                self.sessionActivationCompletionHandlers.removeAll()
            }
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(message)
    }
    
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handle(userInfo)
    }
    
#if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    public func sessionDidDeactivate(_ session: WCSession) {
        // 支持在 iOS 应用程序中快速切换 Apple Watch 设备
        defaultSession.activate()
    }
    
#endif
    
    
    // MARK: - 结构体
    
    public struct MessageKey: RawRepresentable, Hashable {
        
        public static var hashDictionary = [String : Int]()
        
        public let rawValue: String
        
        public let hashValue: Int
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        public static func ==(lhs: MessageKey, rhs: MessageKey) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    public struct MessageHandler: Hashable {
        
        fileprivate let uuid: UUID
        
        fileprivate let handler: (([MessageKey : Any]) -> Void)
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        
        public func invalidate() {
            let manager: WatchConnector? = WatchConnector.shared
            manager?.removeMessageHandler(self)
        }
        
        public init(handler: @escaping (([MessageKey : Any]) -> Void)) {
            self.handler = handler
            self.uuid = UUID()
        }
        
        public static func ==(lhs: MessageHandler, rhs: MessageHandler) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
}
