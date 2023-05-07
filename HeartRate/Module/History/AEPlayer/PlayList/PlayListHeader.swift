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
    static var selectedIndex = 0
    private var titleLabel: UILabel!
    private var fileCountLabel: UILabel!
    private var descriptionLabel: UILabel!
    public var segmentedControl: UISegmentedControl!
    
    func configure(fileCount: Int) {
        fileCountLabel.text = "(\(fileCount))"
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
    
        // Segmented control
        segmentedControl = UISegmentedControl(items: ["已录制", "音频包"])
        segmentedControl.selectedSegmentIndex =  PlayListHeader.selectedIndex
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(30)
        }

        // File count label
        fileCountLabel = UILabel()
        fileCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        fileCountLabel.textColor = .white
        addSubview(fileCountLabel)
        fileCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
        }

    }
}
