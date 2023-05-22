//
//  HorizontalScrollView.swift
//  HRTune
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

public enum ParallaxAcceleration {
    case invariable(CGPoint)
    case variable(((_ parallaxScrollView: ParallaxScrollView, _ view: UIView) -> CGPoint))
}


public struct HorizontalParallaxScrollViewItem {
    let view: UIView
    let originOffset: CGPoint
    let acceleration: ParallaxAcceleration
    let progress: ((_ parallaxScrollView: ParallaxScrollView, _ view: UIView) -> Void)
    
    public init(view: UIView,
                originOffset: CGPoint = CGPoint.zero,
                acceleration: ParallaxAcceleration,
                progress: @escaping ((_ parallaxScrollView: ParallaxScrollView, _ view: UIView) -> Void) = { _ ,_ in }) {
        self.view = view
        self.originOffset = originOffset
        self.acceleration = acceleration
        self.progress = progress
    }
}

public class ParallaxScrollView: UIScrollView {
    
    private var GuideItems: [HorizontalParallaxScrollViewItem] = []
    
    public init(frame: CGRect, items: [HorizontalParallaxScrollViewItem]) {
        self.GuideItems = items
        super.init(frame: frame)

        for item in GuideItems {
            addSubview(item.view)
        }

        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.delegate = self
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    
    private func applyParallaxEffect() {
        let contentOffsetX = contentOffset.x
        
        for item in GuideItems {
            let acceleration: CGPoint
            
            switch item.acceleration {
            case .invariable(let value):
                acceleration = value
            case .variable(let closure):
                acceleration = closure(self, item.view)
            }
            
            item.view.layer.setAffineTransform(CGAffineTransform(translationX: contentOffsetX * (1.0 - acceleration.x),
                                                                  y: contentOffsetX * acceleration.y))
            item.progress(self, item.view)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateParallaxLayout()
    }
    
    func updateParallaxLayout() {
        let contentWidth = bounds.width * CGFloat(GuideItems.count)

        for (index, item) in GuideItems.enumerated() {
            item.view.frame.origin = CGPoint(x: bounds.width * CGFloat(index), y: item.originOffset.y)
        }

        self.contentSize = CGSize(width: contentWidth, height: bounds.height)
    }

}

extension ParallaxScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyParallaxEffect()
    }
}
