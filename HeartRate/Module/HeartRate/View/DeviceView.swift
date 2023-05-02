//
//  DeviceView.swift
//  WatchKit App Extension
//
//  Created by kaoji on 4/20/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit

class DeviceView: UIView {
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        // 添加大图
        imageView.image = R.image.device()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        // 添加底部label
        label.text = "⚠️ 请佩戴解锁已安装程序的iWatch"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        observeConnection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func setupView() {
        backgroundColor = BPMViewConfig.backgroundColor
        addSubview(imageView)
        addSubview(statusLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(imageView.snp.width)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
    }   
    
    func observeConnection(){
        
//        WatchConnector.shared?.onReachabilityChange = { [weak self] isReach in
//            DispatchQueue.main.async {
//                self?.statusLabel.text = isReach ?"设备已连接":"设备未连接"
//                self?.statusLabel.textColor = isReach ?.green:.red
//                self?.imageView.image = UIImage(named: (isReach ?"device":"deviceGray")) 
//            }
//        }
    }

}
