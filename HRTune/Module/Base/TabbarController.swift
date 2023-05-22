//
//  TabbarController.swift
//  HRTune
//
//  Created by kaoji on 5/21/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import UIKit
import Foundation

public extension UIView {
    
    private struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "TapAssociatedObjectKey"
    }
    
    typealias Action = (() -> Void)?

    var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
        }
    }
    
    func TapLisner(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
}

open class TabbarController: UITabBarController {
    
    public var myScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    public var myScreenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public var isCurvedTabbar : Bool = true
    public var centerButtonBottomMargin : CGFloat = 20.0
    public var centerButtonSize : CGFloat = 0.0
    public var centerButtonBackroundColor : UIColor =  #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    public var centerButtonBorderColor : UIColor =  #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    public var centerButtonBorderWidth : CGFloat = 3
    public var centerButtonImage : UIImage?
    public var centerButtonImageSize :  CGFloat = 25.0
    
    private var blockView : UIView?
    private var centreButtonContainer : UIView?
    public var shapeLayer: CALayer?

    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func setupCenetrButton(vPosition : CGFloat ,  buttonClicked: @escaping()->Void )  {
        if isCurvedTabbar {
            makeTabbarCurved()
        }
        
        let safeAreaInsets = getSafeAreaInsets()
        configureCenterButtonContainer(vPosition: vPosition, bottomSafeArea: safeAreaInsets.bottom, buttonClicked: buttonClicked)
    }
    
    private func getSafeAreaInsets() -> (top: CGFloat, bottom: CGFloat) {
        if #available(iOS 11.0, *) {
            return (top: view.safeAreaInsets.top, bottom: view.safeAreaInsets.bottom)
        } else {
            return (top: topLayoutGuide.length, bottom: bottomLayoutGuide.length)
        }
    }
    
    private func configureCenterButtonContainer(vPosition: CGFloat, bottomSafeArea: CGFloat, buttonClicked: @escaping () -> Void) {
        centreButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: centerButtonSize , height: centerButtonSize))
        guard let centreButtonContainer = centreButtonContainer else { return }
        centreButtonContainer.layer.cornerRadius = centerButtonSize / 2

        centerButtonBottomMargin = bottomSafeArea == 0 ? centerButtonSize + 20 : bottomSafeArea + tabBar.frame.height
        centerButtonBottomMargin += vPosition

        centreButtonContainer.frame.origin.y = self.view.bounds.height - centerButtonBottomMargin
        centreButtonContainer.frame.origin.x = self.view.bounds.width/2 - centreButtonContainer.frame.width/2
        
        configureCenterButtonUI()

        let centerButtonImageView = UIImageView(frame: CGRect(x: 0 , y: 0, width: centerButtonImageSize, height: centerButtonImageSize))
        centerButtonImageView.center = CGPoint(x: centreButtonContainer.frame.size.width  / 2,
                                               y: centreButtonContainer.frame.size.height / 2)
        centerButtonImageView.image = centerButtonImage

        centreButtonContainer.addSubview(centerButtonImageView)
        centreButtonContainer.TapLisner {
            buttonClicked()
        }
    }
    
    private func configureCenterButtonUI() {
        guard let centreButtonContainer = centreButtonContainer else { return }
        centreButtonContainer.backgroundColor = centerButtonBackroundColor
        centreButtonContainer.layer.borderColor = centerButtonBorderColor.cgColor
        centreButtonContainer.layer.borderWidth = centerButtonBorderWidth
        centreButtonContainer.clipsToBounds = true
        
        blockView = UIView(frame: CGRect(x: centreButtonContainer.center.x , y: centreButtonContainer.frame.minY, width: centerButtonSize + 20 , height: self.tabBar.frame.height))
        guard let blockView = blockView else { return }
        blockView.backgroundColor = UIColor.clear
        blockView.alpha = 1.0
        blockView.center.x = centreButtonContainer.center.x
        
        self.view.addSubview(blockView)
        self.view.addSubview(centreButtonContainer)
        self.view.bringSubviewToFront(centreButtonContainer)
    }

    public func makeTabbarCurved() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3
        
        if let oldShapeLayer = self.shapeLayer {
            self.tabBar.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.tabBar.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
        
        let blurEffect = UIBlurEffect(style: .light) // 你可以根据你的需求选择不同的模糊样式
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        backgroundView.frame = self.tabBar.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.tabBar.addSubview(backgroundView)
        self.tabBar.sendSubviewToBack(backgroundView)

    }
    
    public func createPath() -> CGPath {
        let height: CGFloat = 35.0
        let path = UIBezierPath()
        let centerWidth = self.tabBar.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough
        
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
        
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))
        
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: self.tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.tabBar.frame.height))
        path.close()
        
        return path.cgPath
    }
}

