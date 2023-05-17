//
//  File.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

//MARK: - 个人资料相关
extension Persist{
    
    func getUserInfo() -> UserEntity? {
        if let userInfo = fetchUserEntity()?.first {
            return userInfo
        } else {
            // 如果表中不存在，则创建新的用户信息
            do {
                let newUser = UserEntity(gender: 0, weight: 60, age: 30, height: 170)
                try database.insert(objects: newUser, intoTable: "UserEntity")
                return newUser
            } catch {
                print("创建UserEntity错误：\(error)")
                return nil
            }
        }
    }
    
    // 更新用户信息
    func updateUserInfo(gender: Int, weight: Int, age: Int, height: Int) {
        do {
            if let userInfo = getUserInfo()  {
                // 更新用户信息
                userInfo.gender = gender
                userInfo.weight = weight
                userInfo.age = age
                userInfo.height = height
                try database.update(table: "UserEntity", on: UserEntity.CodingKeys.all, with: userInfo)
            }
        } catch {
            print("更新用户信息错误：\(error)")
        }
    }
    
    // 内嵌函数 先查询是否有
    func fetchUserEntity()-> [UserEntity]?{
        do {
            return try database.getObjects(fromTable: "UserEntity")
        } catch {
            print("获取UserEntity错误：\(error)")
            return []
        }
    }
}
