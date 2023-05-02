//
//  Recordself.swift
//  HRate
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import KDCircularProgress
import Charts


class BPMView: UIView {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag() // RxSwift资源清理工具
    
    // MARK: - UI Elements
    
    lazy var titleLabel: Label = { // 标题
        let label = Label(style: .appTitle, "HRate")
        return label
    }()
    
    lazy var nowLabel: Label = { // 当前心率
        let label = Label(style: .nowBPMHeading, "0")
        return label
    }()
    
    lazy var timeLabel: Label = { // 录制时间
        let label = Label(style: .time, "00:00")
        return label
    }()
    
    lazy var timeTitleLabel: Label = { // 录制时间标题
        let label = Label(style: .timeTitle, "时间")
        return label
    }()
    
    lazy var progress: KDCircularProgress = { // 心率进度条
        let progress = KDCircularProgress(
            frame: CGRect(x: 0, y: 0, width: self.frame.width / 1.2, height: self.frame.width / 1.2)
        )
        return progress
    }()
    
    lazy var verticalStack: StackView = { // 竖直方向的StackView，包含当前心率、录制时间、录制时间标题
        let stack = StackView(axis: .vertical)
        return stack
    }()
    
    lazy var avgBar: AvgMinMaxBar = { // 平均心率、最小心率、最大心率条形图
        let bar = AvgMinMaxBar()
        return bar
    }()
    
    lazy var containerForSmallDisplay: UIView = { // 小屏幕显示容器
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var deviceView: DeviceView = { // 小屏幕显示容器
        let view = DeviceView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var chart: BarChartView = { // 心率历史记录图表
        let chart = BarChartView()
        chart.noDataTextColor = BPMViewConfig.noDataTextColor
        chart.noDataText = BPMViewConfig.noDataText
        
        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.highlightPerTapEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        chart.legend.enabled = false
        chart.chartDescription.enabled = false
        
        chart.rightAxis.enabled = false
        chart.leftAxis.labelTextColor = BPMViewConfig.labelTextColor
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawLabelsEnabled = false
        
        chart.leftAxis.axisMinimum = BPMViewConfig.axisMinimum
        chart.leftAxis.axisMaximum = BPMViewConfig.axisMaximum
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        
        return chart
    }()
    
    lazy var recordButton: RecordButton = { // 录制按钮
        let button = RecordButton.init(frame: .init(x: 0, y: 0, width: 80, height: 80), shutterType: .normal, buttonColor: .white)
        return button
    }()
    
    lazy var historyButton: UIButton = { // 历史记录按钮
        let button = UIButton()
        button.setImage(R.image.usB(), for: .normal)
        return button
    }()
    
    lazy var userInfoButton: UIButton = { // 录制视频按钮
        let button = UIButton()
        button.setImage(R.image.user(), for: .normal)
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
        backgroundColor = BPMViewConfig.backgroundColor
        
        addSubview(titleLabel)
        addSubview(progress)
        addSubview(verticalStack)
        addSubview(recordButton)
        addSubview(userInfoButton)
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
        
        addSubview(deviceView)
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
        
        
        userInfoButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(80)
            make.bottom.equalToSuperview().offset(-34)
        }
        
        deviceView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(recordButton.snp.top)
        }
    }
    
    //MARK: - 圆环
    private func setupCircleView() {
        progress.startAngle = BPMViewConfig.startAngle
        progress.progressThickness = BPMViewConfig.progressThickness
        progress.trackThickness = BPMViewConfig.trackThickness
        progress.glowMode = BPMViewConfig.glowMode
        progress.trackColor = BPMViewConfig.trackColor!
        progress.set(colors: BPMViewConfig.progressColors[0], BPMViewConfig.progressColors[1], BPMViewConfig.progressColors[2])
        
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
        
        viewModel.workData.bind(to: self.rx.workData).disposed(by: disposeBag)

        // 图表更新
        viewModel.charData.bind(to: chart.rx.data).disposed(by: disposeBag)
        
        //更新录音时间
        viewModel.time.bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        
        // 绑定 录音按钮
        recordButton.rxTapClosure().bind(to: viewModel.recordButtonTapped).disposed(by: disposeBag)
        
        // 绑定 录视频按钮
        userInfoButton.rxTapClosure().bind(to: viewModel.userInfoButtonTapped).disposed(by: disposeBag)
        
        //绑定录音按钮是否可用
        viewModel.recordButtonEnabled.bind(to: recordButton.rx.isEnabled).disposed(by: disposeBag)
        
        //区分录制和非录制UI
        viewModel.isRecording.bind(to: self.rx.isRecording).disposed(by: disposeBag)
        
        // 绑定 历史按钮点击事件
        historyButton.rxTapClosure().bind(to: viewModel.historyButtonTapped).disposed(by: disposeBag)
        
        viewModel.isRecording.bind(to: self.deviceView.rx.isHidden).disposed(by: disposeBag)
    }
}
