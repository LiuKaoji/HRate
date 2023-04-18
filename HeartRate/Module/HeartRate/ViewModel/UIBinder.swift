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
    var data: Binder<[Int16]> {
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

extension Reactive where Base: LineChartView {
    var data: Binder<[Int16]> {
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
            lineDataSet.setColor(.red)
            lineDataSet.drawCirclesEnabled = false
            lineDataSet.lineWidth = 2
            lineDataSet.mode = .cubicBezier
            lineDataSet.drawFilledEnabled = true
            lineDataSet.fillColor = UIColor.systemRed.withAlphaComponent(0.5)
            
            let lineData = LineChartData(dataSet: lineDataSet)
            chartView.data = lineData
            chartView.lineData?.setDrawValues(false)
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


