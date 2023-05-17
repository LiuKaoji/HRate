//
//  PlayListCell.swift
//  HRTune
//
//  Created by kaoji on 4/17/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import AEAudio

class PlayListCell: UITableViewCell{
    
    private let selectedBackgroundViewColor = RecordViewConfig.backgroundColor!.withAlphaComponent(0.3)
    private let unselectedBackgroundViewColor = RecordViewConfig.backgroundColor!.withAlphaComponent(0.7)
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    private let starImageView = UIImageView()
    
    
    private let musicIndicator = ESTMusicIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        backgroundColor = .clear
        musicIndicator.tintColor = R.color.colorCircleOne()!
        musicIndicator.state = .stopped
        //        // 设置选中背景颜色
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.black
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .white.withAlphaComponent(0.9)
        contentView.addSubview(nameLabel)
        
        starImageView.image = P.image.favor()
        starImageView.isHidden = true
        contentView.addSubview(starImageView)
        
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = .white.withAlphaComponent(0.7)
        contentView.addSubview(durationLabel)
        
        // Add musicIndicator to contentView
        contentView.addSubview(musicIndicator)
    }
    
    
    private func setupConstraints() {
        musicIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(musicIndicator.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(starImageView.snp.leading).offset(-10)
        }

        starImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(durationLabel.snp.leading).offset(-8)
            make.size.equalTo(15)
        }

        durationLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        durationLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        durationLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    func configure(with playable: AudioPlayable) {
            nameLabel.text = playable.audioName()
            durationLabel.text = playable.audioDurationText()
            starImageView.isHidden = !playable.isMarkFavor()
        }
    
    func setMusicIndicatorState(_ state: ESTMusicIndicatorViewState) {
        musicIndicator.state = state
    }
}
