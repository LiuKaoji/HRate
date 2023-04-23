//
//  WorkoutData.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/23/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

// 处理成传输Data
//let bpmData = bpmCalculator.createBPMData()
//let encodedData = try NSKeyedArchiver.archivedData(withRootObject: bpmData, requiringSecureCoding: false)

// 解压还原
//if let decodedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedData) as? BPMData {
//    // 使用解码后的数据
//}

class WorkoutData: NSObject, NSCoding {
    var date: Date
    var nowBPM: Int
    var minBPM: Int
    var maxBPM: Int
    var avgBPM: Int
    var bpmPercent: Double
    var totalCalories: Double
    var bpmData: [Int]
    
    init(date: Date, nowBPM: Int, minBPM: Int, maxBPM: Int, avgBPM: Int, bpmPercent: Double, totalCalories: Double, bpmData: [Int]) {
        self.date = date
        self.nowBPM = nowBPM
        self.minBPM = minBPM
        self.maxBPM = maxBPM
        self.avgBPM = avgBPM
        self.bpmPercent = bpmPercent
        self.totalCalories = totalCalories
        self.bpmData = bpmData
    }
    
    required init?(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObject(forKey: "date") as! Date
        nowBPM = aDecoder.decodeInteger(forKey: "nowBPM")
        minBPM = aDecoder.decodeInteger(forKey: "minBPM")
        maxBPM = aDecoder.decodeInteger(forKey: "maxBPM")
        avgBPM = aDecoder.decodeInteger(forKey: "avgBPM")
        bpmPercent = aDecoder.decodeDouble(forKey: "bpmPercent")
        totalCalories = aDecoder.decodeDouble(forKey: "totalCalories")
        bpmData = aDecoder.decodeObject(forKey: "bpmData") as! [Int]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(nowBPM, forKey: "nowBPM")
        aCoder.encode(minBPM, forKey: "minBPM")
        aCoder.encode(maxBPM, forKey: "maxBPM")
        aCoder.encode(avgBPM, forKey: "avgBPM")
        aCoder.encode(bpmPercent, forKey: "bpmPercent")
        aCoder.encode(totalCalories, forKey: "totalCalories")
        aCoder.encode(bpmData, forKey: "bpmData")
    }
}
