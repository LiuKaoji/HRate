//
//  AudioCell.swift
//  HeartRate
//
//  Created by kaoji on 4/17/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit

class AudioCell: UITableViewCell{
    
    private let selectedBackgroundViewColor = StyleConfig.backgroundColor!.withAlphaComponent(0.8)
    private let unselectedBackgroundViewColor = StyleConfig.backgroundColor!.withAlphaComponent(0.5)
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    private let sizeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()

        // 设置背景颜色
        let backgroundView = UIView()
        backgroundView.backgroundColor = unselectedBackgroundViewColor
        self.backgroundView = backgroundView
        
        // 设置选中背景颜色
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = selectedBackgroundViewColor
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .white
        contentView.addSubview(nameLabel)
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        dateLabel.textColor = .white
        contentView.addSubview(dateLabel)
        
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = .white
        contentView.addSubview(durationLabel)
        
        sizeLabel.font = .systemFont(ofSize: 14)
        sizeLabel.textColor = .gray
        sizeLabel.textColor = .white
        contentView.addSubview(sizeLabel)
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameLabel)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(durationLabel)
            make.centerY.equalTo(dateLabel)
        }
    }
    
    func configure(with audioEntity: AudioEntity) {
        nameLabel.text = audioEntity.name
        dateLabel.text = audioEntity.date
        durationLabel.text = audioEntity.duration
        sizeLabel.text = audioEntity.size
    }

}
