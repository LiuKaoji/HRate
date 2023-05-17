//
//  AutoHideLabel.swift
//  AEAudio
//
//  Created by kaoji on 5/5/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

class AutoHideLabel: UILabel {
    
    private let hideDelay: TimeInterval = 7.0
    private var hideTask: DispatchWorkItem?
    
    func setTextWithAutoHide(_ text: String) {
        // 取消之前的稍后隐藏任务
        hideTask?.cancel()
        
        // 显示文本
        self.isHidden = false
        self.text = text
        
        // 创建一个新的任务
        hideTask = DispatchWorkItem { [weak self] in
            self?.isHidden = true
        }
        
        // 稍后隐藏文本
        if let task = hideTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay, execute: task)
        }
    }
    
    deinit{
        hideTask?.cancel()
    }
}
