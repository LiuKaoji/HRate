//
//  PagingView.swift
//  HRTune
//
//  Created by kaoji on 5/13/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

protocol PagingViewDelegate: AnyObject {
    func pagingView(_ pagingView: PagingView, didSelectPageAtIndex index: Int)
}

//MARK: - 分页视图类
open class PagingView: UIView {
    // 页面数，改变时更新图层
    public var count: Int = 1 { didSet { updateLayers() } }
    // 水平间距，改变时更新图层
    public var hSpacing: CGFloat = 12 { didSet { updateLayers() } }
    // 垂直间距，改变时更新图层
    public var vSpacing: CGFloat = 0 { didSet { updateLayers() } }
    // 选中项目的颜色，改变时更新图层
    public var selectedColor: UIColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1) { didSet { updateLayers() } }
    // 项目颜色，改变时更新图层
    public var color: UIColor = .white { didSet { updateLayers() } }
    // 选中的项目索引，改变时更新图层
    public var selected: Int = 0 { didSet { updateLayers(); delegate?.pagingView(self, didSelectPageAtIndex: selected) } }
    // 项目是否显示为圆形，改变时更新图层
    public var isCircles: Bool = false { didSet { updateLayers() } }
    // 动画持续时间
    public var fillingAnimationDuration: TimeInterval = 0, scalingAnimationDuration: TimeInterval = 0
    // 缩放动画倍数
    public var scalingAnimationFactor: CGFloat = 1
    // 圆角大小的倍数
    public var cornerRadiusFactor: CGFloat = 0
    // 最小项目高度和宽度
    private var minItemHeight: CGFloat = 1, minItemWidth: CGFloat = 16
    // 类名
    private var className = String(describing: PagingView.self)
    
    // 代理
    weak var delegate: PagingViewDelegate?
    
    // 更新视图布局
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    // 转到上一个项目
    public func prevItem() { selected = (selected - 1 + count) % count }
    // 转到下一个项目
    public func nextItem() { selected = (selected + 1) % count }
    // 转到指定项目
    public func toItem(index: Int) { selected = index }
    
    // 更新图层
    private func updateLayers() {
        layer.sublayers?.filter { $0.name?.contains(className) == true }.forEach { $0.removeFromSuperlayer() }
        let layers = isCircles ? circlesLayers() : stripesLayers()
        layers.forEach { layer in
            self.layer.addSublayer(layer)
            if layer.name == self.className.appending(String(self.selected)) {
                self.animationChange(for: layer)
            }
        }
    }
    
    
    func nameForLayer(with index: Int) -> String {
        return className.appending(String(index))
    }
    
    // 添加滑动手势识别器
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizers()
    }

    private func setupGestureRecognizers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            nextItem()
        case .right:
            prevItem()
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self)
        guard let layers = layer.sublayers?.filter({ $0.name?.contains(className) == true }) else { return }

        for (index, layer) in layers.enumerated() {
            if layer.frame.contains(tapLocation) {
                selected = index
                break
            }
        }
    }

}

//MARK: - 分页视图图层类型的私有扩展
fileprivate extension PagingView {
    func stripesLayers() -> [CALayer] {
        var layers = [CALayer]()
        
        let hSpace = hSpacing
        let pages = CGFloat(count)
        
        let allHSpace = hSpace * (pages + 1)
        
        var partHeight = bounds.height - vSpacing * 2
        partHeight = partHeight >= minItemHeight ? partHeight : minItemHeight
        
        var partWidth = (bounds.width - allHSpace) / pages
        partWidth = partWidth >= minItemWidth ? partWidth : minItemWidth
        
        var partX = hSpace
        let partY = bounds.height / 2 - partHeight / 2
        
        (0..<count).forEach { index in
            let layer = CALayer()
            layer.name = nameForLayer(with: index)
            layer.frame = CGRect(x: partX, y: partY, width: partWidth, height: partHeight)
            layer.cornerRadius = cornerRadiusFactor != 0 ? partHeight / cornerRadiusFactor : 0
            layer.backgroundColor = color.cgColor
            layers.append(layer)
            
            partX += hSpace + partWidth
        }
        return layers
    }
    
    func circlesLayers() -> [CALayer] {
        var layers = [CALayer]()
        
        let hSpace = hSpacing
        let pages = CGFloat(count)
        let allHSpace = hSpacing * (pages + 1)
        
        var partHeight = bounds.height - vSpacing * 2
        partHeight = partHeight >= minItemHeight ? partHeight : minItemHeight
        
        let partWidth = partHeight
        let workingWidth = allHSpace + (pages * partHeight)
        
        let width = (bounds.width / 2) - (workingWidth / 2)
        
        var partX = width + hSpacing
        partX = partX >= hSpace ? partX : hSpace
        
        let partY = bounds.height / 2 - partWidth / 2
        
        (0..<count).forEach { index in
            let layer = CALayer()
            layer.name = nameForLayer(with: index)
            layer.frame = CGRect(x: partX, y: partY, width: partWidth, height: partHeight)
            layer.cornerRadius = cornerRadiusFactor != 0 ? partHeight / cornerRadiusFactor : 2
            layer.backgroundColor = color.cgColor
            layers.append(layer)
            
            partX += hSpace + partWidth
        }
        return layers
    }
}

//MARK: - 分页视图动画的私有扩展
fileprivate extension PagingView {
    func animationChange(for layer: CALayer) {
        let factor = scalingAnimationFactor
        
        defer {
            layer.backgroundColor = selectedColor.cgColor
            layer.transform = CATransform3DMakeScale(factor, factor, 0)
        }
        
        let animationsGroup = CAAnimationGroup()
        animationsGroup.animations = [CAAnimation]()
        
        if fillingAnimationDuration != 0 {
            let fillingAnimation = CALayer.fillingAnimation(
                from: color.cgColor,
                to: selectedColor.cgColor,
                with: fillingAnimationDuration)
            
            layer.add(fillingAnimation, forKey: "fillingAnimation")
            animationsGroup.animations?.append(fillingAnimation)
        }
        
        if scalingAnimationFactor != 0 {
            let scalingAnimation = CALayer.scalingAnimation(
                with: factor,
                with: scalingAnimationDuration)
            
            layer.add(scalingAnimation, forKey: "scalingAnimation")
            animationsGroup.animations?.append(scalingAnimation)
        }
    }
}

//MARK: - CALayer 扩展
extension CALayer {
    class func fillingAnimation(from colorFrom: CGColor,
                                to colorTo: CGColor,
                                with duration: TimeInterval = 0) -> CABasicAnimation {
        let fillingAnimation = CABasicAnimation(keyPath: "backgroundColor")
        fillingAnimation.fromValue = colorFrom
        fillingAnimation.toValue = colorTo
        fillingAnimation.duration = duration
        fillingAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        return fillingAnimation
    }
    class func scalingAnimation(with factor: CGFloat,
                                with duration: TimeInterval = 0) -> CABasicAnimation {
        let scalingAnimation = CABasicAnimation(keyPath: "transform.scale")
        scalingAnimation.fromValue = CGAffineTransform.identity
        scalingAnimation.toValue = CATransform3DMakeScale(factor, factor, 0)
        scalingAnimation.duration = duration
        scalingAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        return scalingAnimation
    }
}
