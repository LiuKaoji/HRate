//
//  RxCastOrThrow.swift
//  MedicalTec
//
//  Created by kaoji on 2021/5/5.
//

import UIKit
import RxCocoa

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
