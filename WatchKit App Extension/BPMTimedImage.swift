//
//  BPMTimedImage.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/20/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import WatchKit

class BPMTimedImage: NSObject {
    private var timer: Timer?
    private var isLargeImageVisible = true
    
    weak var interfaceImage: WKInterfaceImage?
    var largeImage: UIImage? = .init(named: "heart")
    var smallImage: UIImage? = .init(named: "heartSmall")
    
    init(interfaceImage: WKInterfaceImage) {
        self.interfaceImage = interfaceImage
    }
    
    // 根据传入的 BPM 设置跳动频率
    func startAnimating(withBPM bpm: Double) {
        stopAnimating()
        
        let interval = 60.0 / bpm
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.toggleImage()
        }
    }
    
    func updateBPM(_ bpm: Double) {
        startAnimating(withBPM: bpm)
    }
    
    // 停止跳动
    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }
    
    // 切换图片
    private func toggleImage() {
        if isLargeImageVisible {
            interfaceImage?.setImage(smallImage)
        } else {
            interfaceImage?.setImage(largeImage)
        }
        
        isLargeImageVisible.toggle()
    }
}
