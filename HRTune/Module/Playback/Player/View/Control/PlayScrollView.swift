//
//  PlayScrollView.swift
//  HRTune
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit
import SnapKit

public class PlayScrollView: UIView {

    private var widthContraint: Constraint? = nil
    private var heightContraint: Constraint? = nil
    
    public var pagingWidth: CGFloat = UIScreen.main.bounds.width * 2 {
        didSet {
            if pagingWidth.isZero {
                widthContraint?.activate()
            } else {
                widthContraint?.deactivate()
                self.scrollView.snp.updateConstraints { (make) -> Void in
                    make.width.equalTo(self.pagingWidth)
                }
            }
        }
    }
    
    public var pagingHeight: CGFloat = 0 {
        didSet {
            if pagingHeight.isZero {
                heightContraint?.activate()
            } else {
                heightContraint?.deactivate()
                self.scrollView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(self.pagingHeight)
                }
            }
        }
    }
    
    private class XXReachableScrollView: UIScrollView {
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return true
        }
        
    }
    
    public lazy var scrollView: UIScrollView! = {
        var v = XXReachableScrollView()
        v.clipsToBounds = false
        v.isPagingEnabled = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        
        self.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(self.pagingWidth).priority(.low)
            make.height.equalTo(self.pagingHeight).priority(.low)
            self.widthContraint = make.width.equalTo(self.snp.width).priority(.high).constraint
            self.heightContraint = make.height.equalTo(self.snp.height).priority(.high).constraint
        }
    }

}

