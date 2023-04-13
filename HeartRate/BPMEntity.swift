//
//  BPMEntity.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import WCDBSwift

final class BPMEntity: TableCodable {
    var id: Int? = nil // Add an identifier
    var bpm: Int16 = 0
    var date: String?
    var ts: TimeInterval = 0
    var audioId: String? = nil
    

    enum CodingKeys: String, CodingTableKey {
        typealias Root = BPMEntity
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id, bpm, date, ts, audioId
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
            ]
        }
    }
}
