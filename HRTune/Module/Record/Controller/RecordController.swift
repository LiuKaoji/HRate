//
//  RecordController.swift
//  HRTune
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import AVFAudio

class RecordController: UIViewController {
    
    // 白色状态栏
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - 属性
    
    private lazy var viewModel = RecordViewModel()
    private lazy var recordView = RecordView(frame: UIScreen.main.bounds)
    private lazy var disposeBag = DisposeBag()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupViewModel()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(hidden: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setupNavigationBar(hidden: false)
    }
    
    // MARK: - 设置视图

    private func setupView() {
        AVAudioSession.switchToRecordMode()
        view.addSubview(recordView)
        
        recordView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 设置ViewModel

    private func setupViewModel() {
        recordView.bindViewModel(to: viewModel)
        
        viewModel.navigateToPlayScreen = { [weak self]  in
            DispatchQueue.main.async {
                let list = PlayController()
                self?.navigationController?.pushViewController(list, animated: true)
            }
        }
        
        viewModel.presentScreen = { [weak self]  info in
            self?.present(info, animated: true)
        }
    }
    
    // MARK: - 设置行为

    private func setupActions() {
        recordView.faqButton.rx.tap.subscribe { _ in
            self.present(FAQController(), animated: true)
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - 设置导航栏

    private func setupNavigationBar(hidden: Bool) {
        navigationController?.navigationBar.isHidden = hidden
    }
}
