//
//  WatchConnector.swift
//  HeartRate
//
//  Created by kaoji on 01/25/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import WatchConnectivity

/// iPhone 和 Apple Watch 之间的通信管理器。
class WatchConnector: NSObject, WCSessionDelegate {
    
    // MARK: - 初始化
    
#if os(iOS)
    /// 一个共享的单例。如果当前设备不支持 Watch Connectivity 框架，则返回 nil。
    static var shared: WatchConnector? {
        if WCSession.isSupported() {
            return WatchConnector.sharedInstance
        }
        return nil
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
    func addMessageHandler(_ messageHandler: MessageHandler) {
        guard !messageHandlers.contains(messageHandler) else{
            return
        }
        messageHandlers.append(messageHandler)
    }
    
    /// 从列表中移除处理程序句柄。
    func removeMessageHandler(_ messageHandler: MessageHandler) {
        if let index = messageHandlers.firstIndex(of: messageHandler) {
            messageHandlers.remove(at: index)
        }
    }
    
    /// 异步激活 wcSession。
    func activate() {
        defaultSession.delegate = self
        defaultSession.activate()
    }
    
    /// 获取已激活的 WCSession。如果当前会话尚未激活，则会先激活它。
    ///
    /// - parameter handler: 如果当前设备不支持 Watch Connectivity，则返回 nil。将从主队列中调用。
    func fetchActivatedSession(handler: @escaping (WCSession) -> Void) {
        
        activate()
        
        if defaultSession.activationState == .activated {
            handler(defaultSession)
        } else {
            sessionActivationCompletionHandlers.append(handler)
        }
    }
    
    /// 获取会话是否可达。
    func fetchReachableState(handler: @escaping (Bool) -> Void) {
        fetchActivatedSession { session in
            handler(session.isReachable)
        }
    }
    
    /// 向配对设备发送消息。如果配对设备不可达，则不会发送该消息。
    func send(_ message: [MessageKey : Any]) {
        fetchActivatedSession { session in
            session.sendMessage(self.sessionMessage(for: message), replyHandler: nil)
        }
    }
    
    /// 传输消息到配对设备。
    func transfer(_ message: [MessageKey : Any]) {
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
        
        if activationState == .activated {
            DispatchQueue.main.async {
                
                self.sessionActivationCompletionHandlers.forEach { $0(session) }
                self.sessionActivationCompletionHandlers.removeAll()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handle(userInfo)
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        // 支持在 iOS 应用程序中快速切换 Apple Watch 设备
        defaultSession.activate()
    }
#endif
    
    
    // MARK: - 结构体
    
    struct MessageKey: RawRepresentable, Hashable {
        
        private static var hashDictionary = [String : Int]()
        
        let rawValue: String
        
        let hashValue: Int
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        init(rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        static func ==(lhs: MessageKey, rhs: MessageKey) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    struct MessageHandler: Hashable {
        
        fileprivate let uuid: UUID
        
        fileprivate let handler: (([MessageKey : Any]) -> Void)
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        
        func invalidate() {
            let manager: WatchConnector? = WatchConnector.shared
            manager?.removeMessageHandler(self)
        }
        
        init(handler: @escaping (([MessageKey : Any]) -> Void)) {
            self.handler = handler
            self.uuid = UUID()
        }
        
        static func ==(lhs: MessageHandler, rhs: MessageHandler) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
}
