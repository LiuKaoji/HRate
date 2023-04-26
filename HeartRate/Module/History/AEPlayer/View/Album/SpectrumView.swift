//
//  SpectrumView.swift
//  BeatRider
//
//  Created by kaoji on 4/16/23.
//

import UIKit


class SpectrumView: UIView {
    
    static var barNumbers: Int = 200
    private var spectrumLayers: [CAShapeLayer] = []
    private var spectrumAngles: [CGFloat] = []
    var smoothFactor: CGFloat = 0.5

    
    static var barWidth: CGFloat = 2
    static var barSpacing: CGFloat = 2
    var minimumBarHeight: CGFloat = 2
    var maximumBarHeight: CGFloat = 24
    var totalDegrees: CGFloat = 360
    var baseColor: UIColor = UIColor.init(red: 92/255, green: 112/255, blue: 190/255, alpha: 1)
    
    let imageViewContainer = UIView()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.image = UIImage.init(contentsOfFile: Bundle.main.path(forResource: "background", ofType: "jpg")!)
        imageView.layer.borderWidth = 10
        imageView.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.2).cgColor
        return imageView
    }()
    
    
    func updateSpectrum(with spectra: [Float]) {
        let containerFrame = imageViewContainer.frame

        DispatchQueue.global(qos: .userInitiated).async {
            let numberOfBars = self.computeNumberOfBars(using: containerFrame)
            SpectrumView.barNumbers = numberOfBars
            let maxValue = spectra.max() ?? 1.0

            for index in 0..<spectra.count {
                let value = spectra[index]
                let normalizedValue = CGFloat(value) / CGFloat(maxValue)
                let height = self.minimumBarHeight + normalizedValue * (self.maximumBarHeight - self.minimumBarHeight)

                DispatchQueue.main.async {
                    self.updateSpectrumLayer(at: index, height: height)
                }
            }
        }
    }


    private func updateSpectrumLayer(at index: Int, height: CGFloat) {
        if height.isNaN || index >= spectrumLayers.count {
            return
        }
        let layer = spectrumLayers[index]
        let angle = spectrumAngles[index]
        
        let radius = (imageViewContainer.frame.width + SpectrumView.barSpacing * 2) / 2
        let path = UIBezierPath()
        let startPoint = CGPoint(x: bounds.midX + cos(angle) * radius,
                                 y: bounds.midY + sin(angle) * radius)
        path.move(to: startPoint)
        path.addLine(to: CGPoint(x: startPoint.x + cos(angle) * height,
                                 y: startPoint.y + sin(angle) * height))
        layer.path = path.cgPath
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        if spectrumLayers.isEmpty {
            addSubview(imageViewContainer)
            imageViewContainer.addSubview(imageView)
            imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
            imageViewContainer.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalToSuperview().multipliedBy(0.7)
            }
            imageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalToSuperview()
            }
            self.layoutIfNeeded()
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageViewContainer.layer.cornerRadius = imageViewContainer.frame.width / 2
            configureSpectrumLayers()
        }
    }
    
    private func configureSpectrumLayers() {
        spectrumLayers.removeAll()
        spectrumAngles.removeAll()
        
        let containerFrame = imageViewContainer.frame
        let numberOfBars = computeNumberOfBars(using: containerFrame)
        let angleIncrement = totalDegrees / CGFloat(numberOfBars) * CGFloat.pi / 180
        var currentAngle: CGFloat = 0
        
        for index in 0..<numberOfBars {
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            
            // 仅在调试模式下设置起点和终点颜色
            #if DEBUG
            if index == 0 {
                shapeLayer.strokeColor = UIColor.green.cgColor
            } else if index == numberOfBars - 1 {
                shapeLayer.strokeColor = UIColor.red.cgColor
            } else {
                shapeLayer.strokeColor = baseColor.cgColor
            }
            #else
            shapeLayer.strokeColor = baseColor.cgColor
            #endif
            
            shapeLayer.lineWidth = SpectrumView.barWidth
            shapeLayer.lineCap = .round
            
            layer.addSublayer(shapeLayer)
            spectrumLayers.append(shapeLayer)
            spectrumAngles.append(currentAngle)
            currentAngle += angleIncrement
        }
    }


    private func computeNumberOfBars(using containerFrame: CGRect) -> Int {
        let circleCircumference = (containerFrame.width + SpectrumView.barSpacing * 2) * CGFloat.pi
        let totalBarWidth = SpectrumView.barWidth + SpectrumView.barSpacing
        let numberOfBars = Int(circleCircumference / totalBarWidth)
        
        // 确保跳动线条数量可以完整填充整个圆形
        let remainder = circleCircumference.truncatingRemainder(dividingBy: totalBarWidth)
        if remainder > 0 {
            return numberOfBars + 1
        }
        return numberOfBars
    }
}


