//
//  Recordself.swift
//  HeartRate
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import KDCircularProgress
import Charts
import SnapKit

class RecordView: UIView {
    
    // MARK: - UI Elements
    lazy var decibelLabel: Label = {
        let label = Label(style: .decibelHeading, "0")
        return label
    }()
    
    lazy var timeLabel: Label = {
        let label = Label(style: .time, "00:00")
        return label
    }()
    
    lazy var timeTitleLabel: Label = {
        let label = Label(style: .timeTitle, "时间")
        return label
    }()
    
    lazy var progress: KDCircularProgress = {
        let progress = KDCircularProgress(
            frame: CGRect(x: 0, y: 0, width: self.frame.width / 1.2, height: self.frame.width / 1.2)
        )
        return progress
    }()
    
    lazy var verticalStack: StackView = {
        let stack = StackView(axis: .vertical)
        return stack
    }()
    
    lazy var avgBar: AvgMinMaxBar = {
        let bar = AvgMinMaxBar()
        return bar
    }()
    
    lazy var containerForSmallDisplay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var chart: BarChartView = {
        let chart = BarChartView()
        chart.noDataTextColor = RecordViewConfig.noDataTextColor
        chart.noDataText = RecordViewConfig.noDataText
        
        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.highlightPerTapEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        chart.legend.enabled = false
        chart.chartDescription.enabled = false
        
        chart.rightAxis.enabled = false
        chart.leftAxis.labelTextColor = RecordViewConfig.labelTextColor
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawLabelsEnabled = false
        
        chart.leftAxis.axisMinimum = RecordViewConfig.axisMinimum
        chart.leftAxis.axisMaximum = RecordViewConfig.axisMaximum
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        
        return chart
    }()
    
    lazy var recordButton: RecordButton = {
        let button = RecordButton.init(frame: .init(x: 0, y: 0, width: 80, height: 80), shutterType: .normal, buttonColor: .white)
        return button
    }()
    
    lazy var historyButton: UIButton = {
        let button = UIButton.init(type: .detailDisclosure)
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        backgroundColor = RecordViewConfig.backgroundColor
        
        addSubview(progress)
        addSubview(verticalStack)
        addSubview(recordButton)
        addSubview(historyButton)
        addSubview(containerForSmallDisplay)

        verticalStack.addArrangedSubview(timeLabel)
        verticalStack.addArrangedSubview(timeTitleLabel)
        
        if Constants().isBig {
            addSubview(avgBar)
            addSubview(chart)
        } else {
            containerForSmallDisplay.addSubview(avgBar)
        }
        
        setupLayout()
        setupCircleView()
    }
    
    //MARK: - 约束
    private func setupLayout() {
        
        verticalStack.setCustomSpacing(10, after: decibelLabel)
        
        progress.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width / 1.2)
            make.height.equalTo(self.frame.width / 1.2)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().dividedBy(Constants().isBig ? 1.9 : 1.5)
        }
        
        verticalStack.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(progress)
        }
        
        if Constants().isBig {
            avgBar.snp.makeConstraints { (make) in
                make.top.equalTo(progress.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
            }
            
            chart.snp.makeConstraints { (make) in
                make.top.equalTo(avgBar.snp.bottom).offset(30)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview()
                make.bottom.equalTo(recordButton.snp.top).offset(-30)
            }
        } else {
            containerForSmallDisplay.snp.makeConstraints { (make) in
                make.top.equalTo(progress.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(recordButton.snp.top)
            }
            
            avgBar.snp.makeConstraints { (make) in
                make.centerX.equalTo(containerForSmallDisplay)
                make.centerY.equalTo(containerForSmallDisplay).offset(-20)
            }
        }
        
        recordButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
            make.bottom.equalToSuperview().offset(-34)
        }
        
        historyButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(80)
            make.bottom.equalToSuperview().offset(-34)
        }
    }
    
    //MARK: - 圆环
    private func setupCircleView() {
        progress.startAngle = RecordViewConfig.startAngle
        progress.progressThickness = RecordViewConfig.progressThickness
        progress.trackThickness = RecordViewConfig.trackThickness
        progress.glowMode = RecordViewConfig.glowMode
        progress.trackColor = RecordViewConfig.trackColor!
        progress.set(colors: RecordViewConfig.progressColors[0], RecordViewConfig.progressColors[1], RecordViewConfig.progressColors[2])
        
        if Constants().screenSize.height <= 667 {
            progress.center = CGPoint(x: self.center.x, y: self.center.y / 1.9)
        } else {
            progress.center = CGPoint(x: self.center.x, y: self.center.y / 1.5)
        }
        
        if Constants().isBig {
            progress.center = CGPoint(x: self.center.x, y: self.center.y / 1.9)
        }
    }
}

extension RecordView {
    
    func updateChartData(bpms: [Int16]) {
        
        var entries = [BarChartDataEntry]()
        for i in 0..<bpms.count {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(bpms[i])))
        }
        let set = BarChartDataSet(entries: entries)
        let data = BarChartData(dataSet: set)
        chart.data = data
        
        set.colors = [UIColor(named: "Color")!]
        
        chart.barData?.setDrawValues(false)
    }
    
    func recordUI(){
        self.recordButton.buttonState = .recording
        self.recordButton.buttonColor = .red
        self.historyButton.isHidden = true
    }
    
    func resetUI(){
    
        self.avgBar.avgBPMLabel.text = "-"
        self.avgBar.nowBPMLabel.text = "-"
        self.avgBar.minBPMLabel.text = "-"
        self.avgBar.maxBPMLabel.text = "-"
        self.timeLabel.text = "00:00"
        self.progress.progress = 0
        self.recordButton.buttonState = .normal
        self.recordButton.buttonColor = .white
        self.historyButton.isHidden = false
        
        let set = BarChartDataSet(entries: [])
        let data = BarChartData(dataSet: set)
        chart.data = data
        chart.updateFocusIfNeeded()
    }
}
