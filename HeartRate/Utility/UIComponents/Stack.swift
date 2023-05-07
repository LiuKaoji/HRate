//
//  Stack.swift
//  HRate
//
//  Created by kaoji on 11/20/21.
//

import UIKit

public class StackView: UIStackView {
    
    init(axis: NSLayoutConstraint.Axis) {
        super.init(frame: .zero)
        
        self.axis = axis
        distribution = axis == .horizontal ? .equalSpacing : .fill
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
