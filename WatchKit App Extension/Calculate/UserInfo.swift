//
//  UserInfo.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

class UserInfo: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    // 用户信息的属性
    var gender: Int
    var weight: Int
    var age: Int
    var height: Int
    
    // 初始化方法
    init(gender: Int, weight: Int, age: Int, height: Int) {
        self.gender = gender
        self.weight = weight
        self.age = age
        self.height = height
    }
    
    // MARK: - NSSecureCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.gender = aDecoder.decodeInteger(forKey: "gender")
        self.weight = aDecoder.decodeInteger(forKey: "weight")
        self.age = aDecoder.decodeInteger(forKey: "age")
        self.height = aDecoder.decodeInteger(forKey: "height")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(weight, forKey: "weight")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(height, forKey: "height")
    }
    
    // MARK: - Update Method
    
    func updateIfNeeded(gender: Int, weight: Int, age: Int, height: Int) -> Bool {
        if self.gender != gender || self.weight != weight || self.age != age || self.height != height {
            self.gender = gender
            self.weight = weight
            self.age = age
            self.height = height
            return true
        }
        return false
    }
    
    // MARK: - Save & Load Methods
    
    private static let UserInfoKey = "UserInfoKey"
    
    static func save(_ userEntity: UserInfo) {
        do {
            let userData = try NSKeyedArchiver.archivedData(withRootObject: userEntity, requiringSecureCoding: true)
            UserDefaults.standard.set(userData, forKey: UserInfoKey)
        } catch {
            print("保存用户信息时出错：", error)
        }
    }
    
    // 如果没有加载到
    static func loadFromCache() -> UserInfo? {
        if let userData = UserDefaults.standard.data(forKey: UserInfoKey) {
            do {
                let userEntity = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UserInfo.self], from: userData) as? UserInfo
                return userEntity
            } catch {
                print("加载用户信息时出错：", error)
            }
        }
        // 如果未找到用户数据，创建并返回一个默认的 UserInfo 对象
        let defaultUserInfo = UserInfo(gender: 0, weight: 60, age: 30, height: 170)
        return defaultUserInfo
    }
}
