//
//  WCErrorParser.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import WatchConnectivity

class WCErrorParser {
    static func parseError(_ errorCode: WCError.Code) -> String {
        switch errorCode {
        case .genericError:
            return "通用错误"
        case .sessionNotSupported:
            return "会话不受支持"
        case .sessionMissingDelegate:
            return "会话缺少代理"
        case .sessionNotActivated:
            return "会话未激活"
        case .deviceNotPaired:
            return "设备未配对"
        case .watchAppNotInstalled:
            return "手表应用未安装"
        case .notReachable:
            return "无法连接"
        case .invalidParameter:
            return "参数无效"
        case .payloadTooLarge:
            return "有效负载过大"
        case .payloadUnsupportedTypes:
            return "有效负载包含不支持的类型"
        case .messageReplyFailed:
            return "消息回复失败"
        case .messageReplyTimedOut:
            return "消息回复超时"
        case .fileAccessDenied:
            return "文件访问被拒绝"
        case .deliveryFailed:
            return "传输失败"
        case .insufficientSpace:
            return "空间不足"
        case .sessionInactive:
            return "会话未激活"
        case .transferTimedOut:
            return "传输超时"
        case .companionAppNotInstalled:
            return "配套应用未安装"
        case .watchOnlyApp:
            return "仅限手表应用"
        @unknown default:
            return "未知错误"
        }
    }
}

enum CustomError: Error {
    case watchCommunicationError
    case userDataEncodingError
    case workoutStartError(Error)
    case sendInfoError(Error)
}

extension CustomError {
    var message: String {
        switch self {
        case .watchCommunicationError:
            return "无法与iWatch建立通讯"
        case .userDataEncodingError:
            return "用户数据打包失败"
        case .workoutStartError(let error):
            return "启动watchApp失败: \(error.localizedDescription)"
        case .sendInfoError(let error):
            return "发送用户信息失败: \(error.localizedDescription)"
        }
    }
}
