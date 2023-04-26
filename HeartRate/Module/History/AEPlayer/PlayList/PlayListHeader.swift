//
//  PlayListHeader.swift
//  HRate
//
//  Created by kaoji on 4/26/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

class PlayListHeader: UIView {
    private var titleLabel: UILabel!
    private var fileCountLabel: UILabel!
    private var descriptionLabel: UILabel!

    func configure(fileCount: Int, description: String) {
        fileCountLabel.text = "(\(fileCount))"
        descriptionLabel.text = description
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Title label
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = "播放列表"
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
        }

        // File count label
        fileCountLabel = UILabel()
        fileCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        fileCountLabel.textColor = .white
        addSubview(fileCountLabel)
        fileCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY).offset(4)
            make.left.equalTo(titleLabel.snp.right).offset(4)
        }

        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(fileCountLabel.snp.bottom).offset(4)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
