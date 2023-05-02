//
//  PlaybackIndicator.swift
//  HRate
//
//  Created by kaoji on 4/18/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import UIKit
import ESTMusicIndicator

class PlaybackIndicator: UIBarButtonItem {
    private var musicIndicator: ESTMusicIndicatorView!

    override init() {
        super.init()

        setupMusicIndicatorBarButtonItem()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupMusicIndicatorBarButtonItem()
    }

    private func setupMusicIndicatorBarButtonItem() {
        // 1. 创建一个ESTMusicIndicatorView实例
        musicIndicator = ESTMusicIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))

        // 3. 设置ESTMusicIndicatorView的动画类型和颜色
        musicIndicator.tintColor = R.color.colorCircleOne()!
        musicIndicator.state = .stopped // 状态可以是.stopped, .playing, .paused
        
        // 4. 将ESTMusicIndicatorView添加到一个自定义的UIView中
        let customButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        customButtonView.addSubview(musicIndicator)
        
        self.customView = customButtonView
    }

    // 在需要的时候，可以通过以下方法来改变指示器的状态：
    func updateMusicIndicatorState(state: ESTMusicIndicatorViewState) {
        musicIndicator.state = state
    }
}

