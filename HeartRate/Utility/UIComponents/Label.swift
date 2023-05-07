//
//  Label.swift
//  HRate
//
//  Created by kaoji on 11/20/21.
//

import UIKit

class Label: UILabel {
    
    enum LabelStyle {
        case heading
        case body
        case separator
        case nowBPMHeading
        case timeTitle
        case time
        case avgMinMax
        case tableLabel
        case titleLabel
        case tableTopText
        case tableBottomText
        case appTitle
        
        var fontData: (name: String, size: CGFloat) {
            switch self {
            case .heading:          return ("OpenSans-Bold", 18)
            case .body:             return ("OpenSans-Regular", 15)
            case .separator:        return ("OpenSans-Regular", 12)
            case .nowBPMHeading:    return ("OpenSans-Bold", 50)
            case .timeTitle:        return ("OpenSans-SemiBold", 10)
            case .time:             return ("OpenSans-Bold", 20)
            case .avgMinMax:        return ("OpenSans-Bold", 15)
            case .tableLabel:       return ("OpenSans-SemiBold", 15)
            case .titleLabel:       return ("OpenSans-SemiBold", 17)
            case .tableTopText:     return ("OpenSans-Regular", 14)
            case .tableBottomText:  return ("OpenSans-Regular", 10)
            case .appTitle:         return ("REEJI-PinboGB", 18)
            }
        }
    }
    
    init(style: LabelStyle, _ text: String?) {
        super.init(frame: .zero)
        
        self.text     = text
        textColor     = .white
        numberOfLines = 0
        textAlignment = style == .tableLabel ? .left : .center
        
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont(name: style.fontData.name, size: style.fontData.size)
        
        if style == .separator {
            self.text = "|"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
