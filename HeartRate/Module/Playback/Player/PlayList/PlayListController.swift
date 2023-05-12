//
//  PlayListController.swift
//  HRate
//
//  Created by kaoji on 4/26/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

class PlayListViewController: UIViewController {
    
    private lazy var playListView = PlayListView.init(viewModel: viewModel, frame: .zero)
    private var viewModel: AudioPlayerViewModel! = nil
    
    convenience init(viewModel: AudioPlayerViewModel){
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(playListView)
        playListView.frame = view.bounds
    }

    func show() {
        playListView.show()
    }

    func hide() {
        playListView.hide()
    }
}
