//
//  PlayerControlView.swift
//  HRate
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class NoHighlightButton: UIButton {
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            // Do nothing, effectively disabling the highlight effect
        }
    }
}


class PlayerControlsView: UIView {
    
    lazy var currentTimeLabel: UILabel = createLabel(text: "00:00", fontSize: 13, alignment: .center)
    lazy var totalTimeLabel: UILabel = createLabel(text: "00:00", fontSize: 13, alignment: .center)
    
    lazy var loopButton: UIButton = createButton(name: "repeatOne")
    lazy var prevButton: UIButton = createButton(name: "backward")
    lazy var playPauseButton: UIButton = createButton(name: "pause")
    lazy var nextButton: UIButton = createButton(name: "forward")
    lazy var playlistButton: UIButton = createButton(name: "playlist")
    
    lazy var slider: UISlider = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerControlsView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayerControlsView() {
        addSubview(slider)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)

        let buttonStack = UIStackView(arrangedSubviews: [loopButton, prevButton, playPauseButton, nextButton, playlistButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .equalSpacing
        addSubview(buttonStack)

        playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        playPauseButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        
        slider.setThumbImage(R.image.thumb()!, for: .normal)
        slider.tintColor = .white
        

        slider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.95)
        }

        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(10)
            make.leading.equalTo(slider.snp.leading)
        }

        totalTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(10)
            make.trailing.equalTo(slider.snp.trailing)
        }

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.95)
            make.height.equalTo(80)
        }
    }
    
    private func createLabel(text: String, fontSize: CGFloat, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = alignment
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = .init(white: 1.0, alpha: 0.6)
        return label
    }
    
    private func createButton(name: String) -> NoHighlightButton {
        let buttonImage = UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
        let button = NoHighlightButton(type: .system)
        button.setImage(buttonImage, for: .normal)
        button.isHighlighted = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }
}
