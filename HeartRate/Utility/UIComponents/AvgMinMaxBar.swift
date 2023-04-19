//
//  AvgMinMaxBar.swift
//  HeartRate
//
//  Created by kaoji on 11/22/21.
//

import UIKit
import SnapKit

class AvgMinMaxBar: UIView {
    
    lazy var avgBPMLabel = Label(style: .avgMinMax, "-")
    lazy var minBPMLabel = Label(style: .avgMinMax, "-")
    lazy var maxBPMLabel = Label(style: .avgMinMax, "-")
    lazy var nowBPMLabel = Label(style: .avgMinMax, "-")

    lazy var nowLabel = Label(style: .avgMinMax, "当前")
    lazy var avgLabel = Label(style: .avgMinMax, "平均")
    lazy var minLabel = Label(style: .avgMinMax, "最小")
    lazy var maxLabel = Label(style: .avgMinMax, "最大")
    
    lazy var mainStack: UIStackView = {
        let s = UIStackView()
        
        s.axis         = .horizontal
        s.alignment    = .fill
        s.distribution = .fillProportionally
        s.spacing      = 50
        
        s.translatesAutoresizingMaskIntoConstraints = false
        
        return s
    }()
    
    lazy var nowStack = StackView(axis: .vertical)
    lazy var avgStack = StackView(axis: .vertical)
    lazy var minStack = StackView(axis: .vertical)
    lazy var maxStack = StackView(axis: .vertical)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainStack)
        
        mainStack.addArrangedSubview(nowStack)
        mainStack.addArrangedSubview(avgStack)
        mainStack.addArrangedSubview(minStack)
        mainStack.addArrangedSubview(maxStack)
        
        nowStack.addArrangedSubview(nowBPMLabel)
        nowStack.addArrangedSubview(nowLabel)
        
        avgStack.addArrangedSubview(avgBPMLabel)
        avgStack.addArrangedSubview(avgLabel)
        
        minStack.addArrangedSubview(minBPMLabel)
        minStack.addArrangedSubview(minLabel)
        
        maxStack.addArrangedSubview(maxBPMLabel)
        maxStack.addArrangedSubview(maxLabel)

        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
