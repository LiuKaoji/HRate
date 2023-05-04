//
//  Public.swift
//  HRate
//
//  Created by kaoji on 4/27/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

@_exported import Foundation
@_exported import UIKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import SnapKit

func toByteString(_ size: UInt64) -> String {
        var convertedValue = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
