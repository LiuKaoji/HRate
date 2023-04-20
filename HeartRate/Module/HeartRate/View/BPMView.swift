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
import RxCocoa
import RxSwift

import Foundation
import KDCircularProgress
import Charts
import SnapKit
import RxCocoa
import RxSwift

class BPMView: UIView {
    
    let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    lazy var titleLabel: Label = {
        let label = Label(style: .appTitle, "HRate")
        return label
    }()
    
    // MARK: - UI Elements
    lazy var nowLabel: Label = {
        let label = Label(style: .nowBPMHeading, "0")
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
        chart.noDataTextColor = StyleConfig.noDataTextColor
        chart.noDataText = StyleConfig.noDataText
        
        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.highlightPerTapEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        chart.legend.enabled = false
        chart.chartDescription.enabled = false
        
        chart.rightAxis.enabled = false
        chart.leftAxis.labelTextColor = StyleConfig.labelTextColor
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawLabelsEnabled = false
        
        chart.leftAxis.axisMinimum = StyleConfig.axisMinimum
        chart.leftAxis.axisMaximum = StyleConfig.axisMaximum
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        
        return chart
    }()
    
    lazy var recordButton: RecordButton = {
        let button = RecordButton.init(frame: .init(x: 0, y: 0, width: 80, height: 80), shutterType: .normal, buttonColor: .white)
        return button
    }()
    
    lazy var historyButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(named: "USB"), for: .normal)
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
    
    private func setupView() {
        backgroundColor = StyleConfig.backgroundColor
        
        addSubview(titleLabel)
        addSubview(progress)
        addSubview(verticalStack)
        addSubview(recordButton)
        addSubview(historyButton)
        addSubview(containerForSmallDisplay)
        
        verticalStack.addArrangedSubview(nowLabel)
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
        
        verticalStack.setCustomSpacing(10, after: nowLabel)
        
        progress.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width / 1.2)
            make.height.equalTo(self.frame.width / 1.2)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().dividedBy(Constants().isBig ? 1.9 : 1.5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(progress.snp.top).offset(-12)
            make.centerX.equalToSuperview()
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
        progress.startAngle = StyleConfig.startAngle
        progress.progressThickness = StyleConfig.progressThickness
        progress.trackThickness = StyleConfig.trackThickness
        progress.glowMode = StyleConfig.glowMode
        progress.trackColor = StyleConfig.trackColor!
        progress.set(colors: StyleConfig.progressColors[0], StyleConfig.progressColors[1], StyleConfig.progressColors[2])
        
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

extension BPMView {

    func bindViewModel(to viewModel: BPMViewModel) {
        // 绑定 nowBPM
        viewModel.nowBPM
            .bind(to: nowLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 绑定 minBPM
        viewModel.minBPM
            .bind(to: avgBar.minBPMLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 绑定 maxBPM
        viewModel.maxBPM
            .bind(to: avgBar.maxBPMLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 绑定 avgBPM
        viewModel.avgBPM
            .bind(to: avgBar.avgBPMLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 图表更新
        viewModel.charData.bind(to: chart.rx.data).disposed(by: disposeBag)
        
        // 心率进度更新
        viewModel.progress.bind(to: progress.rx.progress).disposed(by: disposeBag)
        
        //更新录音时间
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        
        // 绑定 录音按钮
        recordButton.rx.tap
                .bind(to: viewModel.recordButtonTapped)
                .disposed(by: disposeBag)
        
        viewModel.recordButtonEnabled.bind(to: recordButton.rx.isEnabled).disposed(by: disposeBag)
        
        //区分录制和非录制UI
        viewModel.isRecording.bind(to: self.rx.isRecording).disposed(by: disposeBag)
        
        // 绑定 历史按钮
        historyButton.rx.tap
                .bind(to: viewModel.historyButtonTapped)
                .disposed(by: disposeBag)
    }
}
