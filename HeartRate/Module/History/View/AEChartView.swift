//
//  StretchyHeaderView.swift
//  HRate
//
//  Created by kaoji on 4/17/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import Charts

class AEChartView: UIView {
    
    
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ""
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var bpmLable: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ""
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    
    lazy var chart: LineChartView = {
        let chart = LineChartView()
        chart.noDataTextColor = BPMViewConfig.noDataTextColor
        chart.noDataText = BPMViewConfig.noDataText2        
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(durationLabel)
        addSubview(chart)
        addSubview(bpmLable)
        
        chart.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.left.right.equalToSuperview().inset(30)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalTo(chart.snp.top)
        }
        
        bpmLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.bottom.equalTo(chart.snp.top)
        }
    }
}
