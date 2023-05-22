//
//  GuideImageLoader.swift
//  HRTune
//
//  Created by kaoji on 5/20/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit

struct G {
    struct image {
        private static let bundle: Bundle = {
            let url = Bundle.main.url(forResource: "Guide", withExtension: "bundle")!
            return Bundle(url: url)!
        }()
        
        static func iphone() -> UIImage? {
            return loadImage(named: "iphone")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func screen_01() -> UIImage? {
            return loadImage(named: "screen_01")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func screen_02() -> UIImage? {
            return loadImage(named: "screen_02")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func screen_03() -> UIImage? {
            return loadImage(named: "screen_03")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func screen_04() -> UIImage? {
            return loadImage(named: "screen_04")?.withRenderingMode(.alwaysOriginal)
        }
        
    
        static func screen_02_bubble() -> UIImage? {
            return loadImage(named: "screen_02_bubble")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func weight() -> UIImage? {
            return loadImage(named: "weight")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func height() -> UIImage? {
            return loadImage(named: "height")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func age() -> UIImage? {
            return loadImage(named: "age")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func cake() -> UIImage? {
            return loadImage(named: "cake")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func screen_04_bubble() -> UIImage? {
            return loadImage(named: "screen_04_bubble")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func screen_05_iphone() -> UIImage? {
            return loadImage(named: "screen_05_iphone")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func watch() -> UIImage? {
            return loadImage(named: "watch")?.withRenderingMode(.alwaysOriginal)
        }
        
        private static func loadImage(named: String) -> UIImage? {
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        }
    }
}
