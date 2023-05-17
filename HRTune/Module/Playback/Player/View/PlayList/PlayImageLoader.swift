//
//  PlayImageLoader.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import UIKit

struct P {
    struct image {
        private static let bundle: Bundle = {
            let url = Bundle.main.url(forResource: "Player", withExtension: "bundle")!
            return Bundle(url: url)!
        }()
        
        static func backward() -> UIImage? {
            return loadImage(named: "backward")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func favorList() -> UIImage? {
            return loadImage(named: "favorList")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func forward() -> UIImage? {
            return loadImage(named: "forward")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func heart() -> UIImage? {
            return loadImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func list() -> UIImage? {
            return loadImage(named: "list")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func musiclist() -> UIImage? {
            return loadImage(named: "musiclist")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func pause() -> UIImage? {
            return loadImage(named: "pause")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func play() -> UIImage? {
            return loadImage(named: "play")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func repeatImage() -> UIImage? {
            return loadImage(named: "repeat")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func repeatOne() -> UIImage? {
            return loadImage(named: "repeatOne")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func shuffle() -> UIImage? {
            return loadImage(named: "shuffle")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func thumb() -> UIImage? {
            return loadImage(named: "thumb")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func waveform() -> UIImage? {
            return loadImage(named: "waveform")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func cover() -> UIImage? {
            return loadImage(named: "cover.jpeg")?.withRenderingMode(.alwaysOriginal)
        }
        
        static func favor() -> UIImage? {
            return loadImage(named: "favor")?.withRenderingMode(.alwaysOriginal)
        }
        
        private static func loadImage(named: String) -> UIImage? {
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        }
    }
}
