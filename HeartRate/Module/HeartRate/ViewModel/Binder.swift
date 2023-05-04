//
//  UIBinder.swift
//  HRate
//
//  Created by kaoji on 4/14/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import Charts
import KDCircularProgress
import AEAudio

// MARK: - 主页UI绑定
///柱状图数据绑定
extension Reactive where Base: BarChartView {
    var data: Binder<[Int]> {
        return Binder(base) { chartView, data in
            if data.count == 0 {
                chartView.data = nil
                chartView.barData?.setDrawValues(false)
                return
            }
            var entries = [BarChartDataEntry]()
            for i in 0..<data.count {
                entries.append(BarChartDataEntry(x: Double(i), y: Double(data[i])))
            }
            let set = BarChartDataSet(entries: entries)
            let charData = BarChartData(dataSet: set)
            set.colors = [UIColor(named: "Color")!]
           chartView.data = charData
           chartView.barData?.setDrawValues(false)
        }
    }
}


// 进度条进度监听
extension Reactive where Base: KDCircularProgress {
    var progress: Binder<Double> {
        return Binder(base) { progressView, progress in
            progressView.progress = progress
        }
    }
}

// 录制与非录制状态UI切换
extension Reactive where Base: BPMView {
    var isRecording: Binder<Bool> {
        return Binder(base) { view, isRecording in
            isRecording ?recordUI():resetUI()
            func recordUI(){
                view.recordButton.buttonState = .recording
                view.recordButton.buttonColor = .red
                view.historyButton.isHidden = true
                view.userInfoButton.isHidden = true
                view.levelMeterView.isHidden = false
            }
            
            func resetUI(){
                view.timeLabel.text = "00:00"
                view.progress.progress = 0
                view.recordButton.buttonState = .normal
                view.recordButton.buttonColor = .white
                view.historyButton.isHidden = false
                view.userInfoButton.isHidden = false
                view.levelMeterView.isHidden = true            }
        }
    }
}


// MARK: - 已录制UI绑定
// 折线图数据绑定
extension Reactive where Base: LineChartView {
    var data: Binder<[Int]> {
        return Binder(base) { chartView, data in
            if data.count == 0 {
                chartView.data = nil
                chartView.lineData?.setDrawValues(false)
                return
            }
            
            var entries = [ChartDataEntry]()
            for i in 0..<data.count {
                let entry = ChartDataEntry(x: Double(i), y: Double(data[i]))
                entries.append(entry)
            }
            
            let lineDataSet = LineChartDataSet(entries: entries, label: "心率")
            lineDataSet.setColor(UIColor.systemRed.withAlphaComponent(0.9))
            lineDataSet.drawCirclesEnabled = false
            lineDataSet.lineWidth = 1
            lineDataSet.mode = .stepped // 使用线性插值以提高波峰尖锐度
            lineDataSet.drawFilledEnabled = true
            lineDataSet.fillColor = UIColor.systemRed.withAlphaComponent(0.5)
            lineDataSet.drawValuesEnabled = false // 不绘制数据点上的值
            
            let lineData = LineChartData(dataSet: lineDataSet)
            chartView.data = lineData
            chartView.lineData?.setDrawValues(false)
            
            // 提高图表的清晰度
            chartView.setScaleEnabled(true)
            chartView.pinchZoomEnabled = true
            chartView.doubleTapToZoomEnabled = true
            chartView.dragEnabled = true
            
            // 设置图例样式
            chartView.legend.textColor = .red
            chartView.legend.font = UIFont.systemFont(ofSize: 12)
        }
    }
}


// workoutData绑定: - 音频播放指示器状态
extension Reactive where Base: BPMView {
    var workData: Binder<WorkoutData> {
        return Binder(base) { view, data in
            view.nowLabel.text = "\(data.nowBPM)"
            view.avgBar.minBPMLabel.text = "\(data.minBPM)"
            view.avgBar.maxBPMLabel.text = "\(data.maxBPM)"
            view.avgBar.avgBPMLabel.text = "\(data.avgBPM)"
            view.progress.progress = data.bpmPercent
        }
    }
}


// 录制历史: - 音频播放指示器状态
extension Reactive where Base: PlaybackIndicator {
    var state: Binder<ESTMusicIndicatorViewState> {
        return Binder(base) { view, state in
            view.updateMusicIndicatorState(state: state)
        }
    }
}

// 录制历史: - 绑定FFT数据
extension Reactive where Base: SpectrumView {
    var spectrum: Binder<[Float]> {
        return Binder(base) { view, spectrum in
            view.updateSpectrum(with: spectrum)
        }
    }
}

extension Reactive where Base: LevelMeterView {
    var state: Binder<AudioLevelProvider> {
        return Binder(base) { view, provider in
            view.levelProvider = provider
        }
    }
}
