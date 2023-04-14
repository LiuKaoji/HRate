//
//  BPMController.swift
//  HeartRate
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import Charts

class BPMController: UIViewController {
    
    // 白色状态栏
    override var preferredStatusBarStyle: UIStatusBarStyle{.lightContent}
    
    // 双向绑定
    private lazy var viewModel = BPMViewModel()
    
    // 视图
    private lazy var bpmView = BPMView.init(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bpmView)
        bpmView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // 绑定 ViewModel
        bpmView.bindViewModel(to: viewModel)
        
        viewModel.navigateToNextScreen = { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
