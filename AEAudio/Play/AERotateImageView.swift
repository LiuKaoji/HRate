//
//  AERotateImageView.swift
//  AEAudio
//
//  Created by kaoji on 4/30/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit

public class AERotateImageView: UIImageView {
    private lazy var rotator = AEViewRotator.init(view: self)
    public lazy var isRotating = false {
        didSet{
            isRotating ?startRotate():pauseRotate()
        }
    }
    
    public func startRotate(){
        rotator.start()
    }
    
    public func pauseRotate(){
        rotator.pause()
    }
    
    private func resumeRotate(){
        rotator.resume()
    }
}
