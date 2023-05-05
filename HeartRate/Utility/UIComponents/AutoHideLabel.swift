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
    
    private let hideDelay: TimeInterval = 3.0
    private var hideTask: DispatchWorkItem?
    
    func setTextWithAutoHide(_ text: String) {
        // Cancel the previous task if any
        hideTask?.cancel()
        
        // Show the label and set the text
        self.isHidden = false
        self.text = text
        
        // Create a new task
        hideTask = DispatchWorkItem { [weak self] in
            self?.isHidden = true
        }
        
        // Schedule the task to be executed after a delay
        if let task = hideTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay, execute: task)
        }
    }
}
