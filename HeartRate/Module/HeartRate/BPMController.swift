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
import AEAudio
import AVFAudio
import WatchConnectivity

class BPMController: UIViewController {
    
    // 白色状态栏
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    let session = RxWCSession()
//    lazy var result = session.activate()

    // 双向绑定
    private lazy var viewModel = BPMViewModel()

    // 视图
    private lazy var bpmView = BPMView(frame: UIScreen.main.bounds)
    
    // dispose
    private lazy var disposeBag = DisposeBag()


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
        AVAudioSession.switchToRecordMode()
        // 添加视图
        view.addSubview(bpmView)
        bpmView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 绑定 ViewModel
        bpmView.bindViewModel(to: viewModel)
        
        // 跳转到下一个视图
        viewModel.navigateToPlayScreen = { [weak self]  in
            DispatchQueue.main.async {
                let list = AEPlayerController()
                self?.navigationController?.pushViewController(list, animated: true)
            }
        }
        
        viewModel.presentScreen = { [weak self]  info in
            self?.present(info, animated: true)
        }
        
        
//        session.isReachable
//            .map { $0 ? "Is reachable" : "Is not reachable" }
//            .subscribe(onNext: { text in
//                print(text)
//            })
//            .disposed(by: disposeBag)
//
//        session.activationState
//            .map { $0 == .activated ? "Activated" : "Not activated" }
//            .subscribe(onNext: { text in
//                print(text)
//            })
//            .disposed(by: disposeBag)
//
//
//        print("Session was activated \(result)")
    }


}
