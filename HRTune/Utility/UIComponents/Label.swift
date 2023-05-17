//
//  Label.swift
//  HRTune
//
//  Created by kaoji on 11/20/21.
//

import UIKit

class Label: UILabel {
    
    enum LabelStyle {
        case nowBPMHeading
        case timeTitle
        case time
        case avgMinMax
        case appTitle
        
        var fontData: (name: String, size: CGFloat) {
            switch self {
            case .nowBPMHeading:    return ("OpenSans-Bold", 50)
            case .timeTitle:        return ("OpenSans-SemiBold", 10)
            case .time:             return ("OpenSans-Bold", 20)
            case .avgMinMax:        return ("OpenSans-Bold", 15)
            case .appTitle:         return ("REEJI-PinboGB", 18)
            }
        }
    }
    
    init(style: LabelStyle, _ text: String?) {
        super.init(frame: .zero)
        
        self.text     = text
        textColor     = .white
        numberOfLines = 0
        textAlignment = .center
        
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont(name: style.fontData.name, size: style.fontData.size)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
