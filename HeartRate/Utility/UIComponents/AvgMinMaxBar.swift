//
//  AvgMinMaxBar.swift
//  HRate
//
//  Created by kaoji on 11/22/21.
//

import UIKit
import SnapKit

class AvgMinMaxBar: UIView {
    
    lazy var avgBPMLabel = Label(style: .avgMinMax, "-")
    lazy var minBPMLabel = Label(style: .avgMinMax, "-")
    lazy var maxBPMLabel = Label(style: .avgMinMax, "-")

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
    
    lazy var stacks: [UIStackView] = {
        return [
            createStack(dataLabel: avgBPMLabel, descriptionLabel: avgLabel),
            createStack(dataLabel: minBPMLabel, descriptionLabel: minLabel),
            createStack(dataLabel: maxBPMLabel, descriptionLabel: maxLabel)
        ]
    }()
    
    private func createStack(dataLabel: UILabel, descriptionLabel: UILabel) -> UIStackView {
        let stack = StackView(axis: .vertical)
        stack.addArrangedSubview(dataLabel)
        stack.addArrangedSubview(descriptionLabel)
        return stack
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainStack)
        stacks.forEach { mainStack.addArrangedSubview($0) }
        
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
