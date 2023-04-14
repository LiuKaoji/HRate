//
//  UIBinder.swift
//  HeartRate
//
//  Created by kaoji on 4/14/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Charts
import KDCircularProgress

extension Reactive where Base: BarChartView {
    var data: Binder<BarChartData> {
        return Binder(base) { chartView, data in
            chartView.data = data
            chartView.barData?.setDrawValues(false)
        }
    }
}

extension Reactive where Base: KDCircularProgress {
    var progress: Binder<Double> {
        return Binder(base) { progressView, progress in
            progressView.progress = progress
        }
    }
}

extension Reactive where Base: BPMView {
    var isRecording: Binder<Bool> {
        return Binder(base) { view, isRecording in
            isRecording ?recordUI():resetUI()
            func recordUI(){
                view.recordButton.buttonState = .recording
                view.recordButton.buttonColor = .red
                view.historyButton.isHidden = true
            }
            
            func resetUI(){
                view.timeLabel.text = "00:00"
                view.progress.progress = 0
                view.recordButton.buttonState = .normal
                view.recordButton.buttonColor = .white
                view.historyButton.isHidden = false
            }
        }
    }
}


