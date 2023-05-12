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
        let stack = UIStackView(axis: .horizontal, spacing: 50)
        stack.addArrangedSubviews(
            [
                createStack(dataLabel: avgBPMLabel, descriptionLabel: avgLabel),
                createStack(dataLabel: minBPMLabel, descriptionLabel: minLabel),
                createStack(dataLabel: maxBPMLabel, descriptionLabel: maxLabel)
            ]
        )
        return stack
    }()
    
    private func createStack(dataLabel: UILabel, descriptionLabel: UILabel) -> UIStackView {
        let stack = UIStackView(axis: .vertical)
        stack.addArrangedSubviews([dataLabel, descriptionLabel])
        return stack
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainStack)
        addConstraintsToFillSuperview(with: mainStack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
