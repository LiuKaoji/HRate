//
//  BPMController.swift
//  HRate
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import Charts

class BPMController: UIViewController {
    
    // 白色状态栏
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // 双向绑定
    private lazy var viewModel = BPMViewModel()

    // 视图
    private lazy var bpmView = BPMView(frame: UIScreen.main.bounds)

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加视图
        view.addSubview(bpmView)
        bpmView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 绑定 ViewModel
        bpmView.bindViewModel(to: viewModel)
        
        // 跳转到下一个视图
        viewModel.navigateToNextScreen = { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        // 弹出页面窗口
        viewModel.presentScreen = { [weak self] vc in
            self?.present(vc, animated: true)
        }
    }

}
