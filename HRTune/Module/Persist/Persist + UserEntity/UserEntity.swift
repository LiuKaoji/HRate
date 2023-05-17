//
//  UserEntity.swift
//  HRTune
//
//  Created by kaoji on 4/22/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import WCDBSwift

// UserInfo 类遵循 TableCodable 协议，这样它可以作为 WCDB 表的模型
final class UserEntity: TableCodable {

    // 定义表中的列名
    enum CodingKeys: String, CodingTableKey {
        typealias Root = UserEntity
        static let objectRelationalMapping = TableBinding(CodingKeys.self)

        // 列名定义
        case gender
        case weight
        case age
        case height

        // 设置表名
        static var tableName: String {
            return "UserEntity"
        }
    }

    // 用户信息的属性
    var gender: Int = 0
    var weight: Int = 0
    var age: Int = 0
    var height: Int = 0

    // 初始化方法
    init(gender: Int, weight: Int, age: Int, height: Int) {
        self.gender = gender
        self.weight = weight
        self.age = age
        self.height = height
    }
}
