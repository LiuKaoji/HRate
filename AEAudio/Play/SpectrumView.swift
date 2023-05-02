//
//  SpectrumView.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

@objc open class SpectrumView: UIView {
    public static var isEnable: Bool = false
    public static var barNumbers: Int = 200
    private var spectrumLayers: [CAShapeLayer] = []
    private var spectrumAngles: [CGFloat] = []
    private static let barWidth: CGFloat = 2, barSpacing: CGFloat = 2, totalDegrees: CGFloat = 360
    private let minimumBarHeight: CGFloat = 2, maximumBarHeight: CGFloat = 14
    private let baseColor = UIColor.init(red: 92/255, green: 112/255, blue: 190/255, alpha: 1)
    public let imageViewContainer = UIView(), imageView: AERotateImageView = {
        let imageView = AERotateImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage.init(contentsOfFile: Bundle.main.path(forResource: "background", ofType: "jpg")!)
        imageView.layer.borderWidth = 10
        imageView.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.2).cgColor
        return imageView
    }()

    public func updateSpectrum(with spectra: [Float]) {
        guard SpectrumView.isEnable else { return }
        let containerFrame = imageViewContainer.frame

        DispatchQueue.global(qos: .userInitiated).async {
            let numberOfBars = self.computeNumberOfBars(using: containerFrame)
            SpectrumView.barNumbers = numberOfBars

            // 按照bar的数量取数据的前四分之一四次
            let halfBars = numberOfBars / 1
            let halfSpectra = Array(spectra.prefix(halfBars))

            var combinedSpectra = halfSpectra + halfSpectra
            let maxValue = combinedSpectra.max() ?? 1.0

            // 首末10位数值逐渐降低
            let barCount = 8
            let maxIndex = min(barCount, combinedSpectra.count) // 防止越界访问
            for i in 0..<maxIndex {
                let progress = Float(i) / Float(barCount)
                combinedSpectra[i] *= progress
                combinedSpectra[combinedSpectra.count - 1 - i] *= progress

                // 连接处数值处理
                combinedSpectra[halfBars - 1 - i] *= progress
//                combinedSpectra[halfBars + i] *= progress
//                combinedSpectra[halfBars * 2 - 1 - i] *= progress
            }

            DispatchQueue.main.async {
                for index in 0..<combinedSpectra.count {
                    let value = combinedSpectra[index]
                    let normalizedValue = CGFloat(value) / CGFloat(maxValue)
                    let height = self.minimumBarHeight + normalizedValue * (self.maximumBarHeight - self.minimumBarHeight)
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


    public override func layoutSubviews() {
        super.layoutSubviews()
        if spectrumLayers.isEmpty {
            addSubview(imageViewContainer)
            imageViewContainer.addSubview(imageView)
            imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageViewContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                imageViewContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                imageViewContainer.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
                imageViewContainer.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7),
                imageView.centerXAnchor.constraint(equalTo: imageViewContainer.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: imageViewContainer.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: imageViewContainer.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: imageViewContainer.heightAnchor)
            ])
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
        let angleIncrement = SpectrumView.totalDegrees / CGFloat(numberOfBars) * CGFloat.pi / 180
        //var currentAngle: CGFloat = 0 //从右侧中间开始
        var currentAngle: CGFloat = -CGFloat.pi

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

            // 添加阴影
            shapeLayer.shadowColor = baseColor.cgColor
            shapeLayer.shadowOffset = CGSize(width: 0, height: 1)
            shapeLayer.shadowRadius = 3
            shapeLayer.shadowOpacity = 0.7

            shapeLayer.lineWidth = SpectrumView.barWidth
            shapeLayer.lineCap = .round

            layer.addSublayer(shapeLayer)
            spectrumLayers.append(shapeLayer)
            spectrumAngles.append(currentAngle)
            currentAngle += angleIncrement

        }
    }

    private func createDefaultPath(with index: Int, currentAngle: CGFloat, radius: CGFloat) -> CGPath {
          let path = UIBezierPath()
          let startPoint = CGPoint(x: bounds.midX + cos(currentAngle) * radius,
                                   y: bounds.midY + sin(currentAngle) * radius)
          path.move(to: startPoint)
          path.addLine(to: CGPoint(x: startPoint.x + cos(currentAngle) * minimumBarHeight,
                                   y: startPoint.y + sin(currentAngle) * minimumBarHeight))
          return path.cgPath
      }

    private func computeNumberOfBars(using containerFrame: CGRect) -> Int {
        let circleCircumference = (containerFrame.width + SpectrumView.barSpacing * 2) * CGFloat.pi
        let totalBarWidth = SpectrumView.barWidth + SpectrumView.barSpacing
        let numberOfBars = Int(circleCircumference / totalBarWidth)
        let numberBands = numberOfBars + (circleCircumference.truncatingRemainder(dividingBy: totalBarWidth) > 0 ? 1 : 0)
        AudioAnalyzer.drawBands = numberBands
        return numberBands
    }
}

