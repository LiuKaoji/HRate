//
//  PlayMode.swift
//  HRTune
//
//  Created by kaoji on 5/3/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import WCDBSwift

public enum PlayMode: Codable {
    case single
    case all
    case random
}


// 记录播放模式
final public class PlayModeEntity: TableCodable {
    
    public enum PlayMode: Int {
        case single = 0
        case all
        case random
    }
    
    private var modeValue: Int = PlayMode.all.rawValue
    var mode: PlayMode {
        get { return PlayMode(rawValue: modeValue) ?? .all }
        set { modeValue = newValue.rawValue }
    }
    var id: Int? // 标识
    
    public init(mode: PlayMode = .all) {
        self.mode = mode
    }

    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = PlayModeEntity
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case modeValue = "mode"
        case id
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                modeValue: ColumnConstraintBinding(isUnique: true),
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
            ]
        }
    }
}


extension PlayModeEntity{
    
    // 获取随机播放索引且不与上次重复(若文件数量>1)
    public func randomIndex(in range: Range<Int>, currentIndex: Int) -> Int {
        guard range.count > 1 else {
            return range.first ?? 0
        }
        
        var randomIndex = Int.random(in: range)
        while randomIndex == currentIndex {
            randomIndex = Int.random(in: range)
        }
        
        return randomIndex
    }
    
    // 当前模式的图片
    public func imageName(for playMode: PlayMode) -> UIImage? {
        switch playMode {
        case .single:
            return P.image.repeatOne()
        case .all:
            return P.image.repeatImage()
        case .random:
            return P.image.shuffle()
        }
    }
    
    // 切换到下一个模式
    public func switchNextMode() -> PlayMode {
        switch mode {
        case .single:
            mode = .all
        case .all:
            mode = .random
        case .random:
            mode = .single
        }
        Persist.shared.savePlayModeEntity(self)
        return mode
    }
}
