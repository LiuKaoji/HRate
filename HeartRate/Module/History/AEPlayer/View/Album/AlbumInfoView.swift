//
//  AEPlayerFirstView.swift
//  HRate
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import AEAudio

class AlbumInfoView: UIView {
    let albumView = createAlbumView()
    let albumCoverView: UIView = UIView()
    
    lazy var titleLabel: UILabel = createLabel(fontSize: 18, alignment: .left)
    lazy var infoLabel: UILabel = createLabel(fontSize: 13, alignment: .left)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAlbumInfoView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAlbumInfoView() {
        let contentViews = [albumCoverView, albumView, titleLabel, infoLabel]
        contentViews.forEach({ addSubview($0) })
        
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .gray

        albumCoverView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(albumCoverView.snp.width)
        }

        albumView.snp.makeConstraints { make in
            make.edges.equalTo(albumCoverView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(albumCoverView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }
    
    private func createLabel(fontSize: CGFloat, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.textAlignment = alignment
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }
    
    private static func createAlbumView() -> SpectrumView {
        let view = SpectrumView()
        view.backgroundColor = .clear
        return view
    }
}
