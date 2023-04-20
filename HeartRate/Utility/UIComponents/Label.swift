//
//  Label.swift
//  HeartRate
//
//  Created by kaoji on 11/20/21.
//

import UIKit


class Label: UILabel {
    
    enum LabelStyle {
        case heading
        case body
        case separator
        case decibelHeading
        case timeTitle
        case time
        case avgMinMax
        case tableLabel
        case titleLabel
        case tableTopText
        case tableBottomText
        case appTitle
    }
    
    init(style: LabelStyle, _ text: String?) {
        super.init(frame: .zero)
        
        self.text     = text
        textColor     = .white
        numberOfLines = 0
        textAlignment = .center
        
        translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .heading:
            font = UIFont(name: "OpenSans-Bold", size: 18)
        case .body:
            font = UIFont(name: "OpenSans-Regular", size: 15)
        case .separator:
            font = UIFont(name: "OpenSans-Regular", size: 12)
            self.text = "|"
        case .decibelHeading:
            font = UIFont(name: "OpenSans-Bold", size: 50)
        case .timeTitle:
            font = UIFont(name: "OpenSans-SemiBold", size: 10)
        case .time:
            font = UIFont(name: "OpenSans-Bold", size: 20)
        case .avgMinMax:
            font = UIFont(name: "OpenSans-Bold", size: 15)
        case .tableLabel:
            font = UIFont(name: "OpenSans-SemiBold", size: 15)
            textAlignment = .left
        case .titleLabel:
            font = UIFont(name: "OpenSans-SemiBold", size: 17)
        case .tableTopText:
            font = UIFont(name: "OpenSans-Regular", size: 14)
        case .tableBottomText:
            font = UIFont(name: "OpenSans-Regular", size: 10)
        case .appTitle:
            font = UIFont(name: "REEJI-PinboGB", size: 18)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
