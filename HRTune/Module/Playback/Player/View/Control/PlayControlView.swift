//
//  PlayControlView.swift
//  HRTune
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class PlayControlView: UIView {
    
    lazy var currentTimeLabel: UILabel = createLabel(text: "00:00", fontSize: 13, alignment: .center)
    lazy var totalTimeLabel: UILabel = createLabel(text: "00:00", fontSize: 13, alignment: .center)
    
    lazy var loopButton: UIButton = createButton(P.image.repeatOne())
    lazy var prevButton: UIButton = createButton(P.image.backward())
    lazy var playPauseButton: UIButton = createButton(P.image.play())
    lazy var nextButton: UIButton = createButton(P.image.forward())
    lazy var playlistButton: UIButton = createButton(P.image.list())
    
    lazy var slider: UISlider = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayControlView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayControlView() {
        addSubview(slider)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)

        let buttonStack = UIStackView(arrangedSubviews: [loopButton, prevButton, playPauseButton, nextButton, playlistButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .equalSpacing
        addSubview(buttonStack)

        let pauseImage = P.image.pause()
        playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        playPauseButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        playPauseButton.setImage(pauseImage, for: .selected)
        
        slider.setThumbImage(P.image.thumb()!, for: .normal)
        slider.tintColor = .white
        

        slider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(10)
        }

        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom)
            make.leading.equalTo(slider.snp.leading)
        }

        totalTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom)
            make.trailing.equalTo(slider.snp.trailing)
        }

        buttonStack.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
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
    
    private func createButton(_ buttonImage: UIImage?) -> UIButton {
        let button = UIButton()
        button.setImage(buttonImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        return button
    }
}
