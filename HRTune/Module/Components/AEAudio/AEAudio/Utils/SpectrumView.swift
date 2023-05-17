//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/post/5c1bbec66fb9a049cb18b64c
// Created by: potato04 on 2019/1/30
//

import UIKit

public class SpectrumView: UIView {
    
    var barWidth: CGFloat = 3.0
    var space: CGFloat = 1.0
    
    private let bottomSpace: CGFloat = 0.0
    private let topSpace: CGFloat = 0.0
    
    var leftGradientLayer = CAGradientLayer()
    var rightGradientLayer = CAGradientLayer()
    
    public var spectra:[[Float]]? {
        didSet {
            if let spectra = spectra {
                guard spectra.count > 0 else {return }

                let leftPath = UIBezierPath()
                for (i, amplitude) in spectra[0].enumerated() {
                    let x = CGFloat(i) * (barWidth + space) + space
                    let y = translateAmplitudeToYPosition(amplitude: amplitude)
                    let bar = UIBezierPath(rect: CGRect(x: x, y: y, width: barWidth, height: bounds.height - bottomSpace - y))
                    leftPath.append(bar)
                }
                let leftMaskLayer = CAShapeLayer()
                leftMaskLayer.path = leftPath.cgPath
                leftGradientLayer.frame = CGRect(x: 0, y: topSpace, width: bounds.width, height: bounds.height - topSpace - bottomSpace)
                leftGradientLayer.mask = leftMaskLayer
                
                // right channel
                let rightChannel = spectra.count >= 2 ? spectra[1] : spectra[0] // if there is only one channel, use the left channel data for the right channel
                let rightPath = UIBezierPath()
                for (i, amplitude) in rightChannel.enumerated() {
                    let x = CGFloat(rightChannel.count - 1 - i) * (barWidth + space) + space
                    let y = translateAmplitudeToYPosition(amplitude: amplitude)
                    let bar = UIBezierPath(rect: CGRect(x: x, y: y, width: barWidth, height: bounds.height - bottomSpace - y))
                    rightPath.append(bar)
                }
                let rightMaskLayer = CAShapeLayer()
                rightMaskLayer.path = rightPath.cgPath
                rightGradientLayer.frame = CGRect(x: 0, y: topSpace, width: bounds.width, height: bounds.height - topSpace - bottomSpace)
                rightGradientLayer.mask = rightMaskLayer
            }
        }
    }

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        rightGradientLayer.colors = [UIColor.init(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0).cgColor,
                                     UIColor.init(red: 0/255, green: 100/255, blue: 0/255, alpha: 1.0).cgColor]
        rightGradientLayer.locations = [0.6, 1.0]
        self.layer.addSublayer(rightGradientLayer)
        
        leftGradientLayer.colors = [UIColor.init(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0).cgColor,
                                    UIColor.init(red: 0/255, green: 0/255, blue: 139/255, alpha: 1.0).cgColor]
        leftGradientLayer.locations = [0.6, 1.0]
        self.layer.addSublayer(leftGradientLayer)
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 1

        self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
    }
    
    private func translateAmplitudeToYPosition(amplitude: Float) -> CGFloat {
        let barHeight: CGFloat = CGFloat(amplitude) * (bounds.height - bottomSpace - topSpace)
        return bounds.height - bottomSpace - barHeight
    }
}
