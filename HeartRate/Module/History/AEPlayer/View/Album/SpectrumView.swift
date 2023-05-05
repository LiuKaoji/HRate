//
//  SpectrumView.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio
import UIKit
import AsyncDisplayKit


@objc open class SpectrumView: ASDisplayNode {
    public static var isEnable: Bool = true
    public static var barNumbers: Int = 200
    private var spectrumLayers: [CAShapeLayer] = []
    private var spectrumAngles: [CGFloat] = []
    private static let barWidth: CGFloat = 2, barSpacing: CGFloat = 2, totalDegrees: CGFloat = 360
    private let minimumBarHeight: CGFloat = 2, maximumBarHeight: CGFloat = 14
    private let baseColor = UIColor.init(red: 92/255, green: 112/255, blue: 190/255, alpha: 1)
    public let imageViewContainerNode = ASDisplayNode()
    public let imageViewNode = AERotateImageNode()
    private let albumWidth = UIScreen.main.bounds.width * 0.7
    private var lastSpectra: [Float]?
    private var hasNewData: Bool = false
    private var lastUpdateTime = DispatchTime.now()

    
    override init() {
        super.init()
        AudioAnalyzer.drawBands = 220
        automaticallyManagesSubnodes = true
        configureSpectrumLayers()
        imageViewNode.image = R.image.backgroundJpg()
        imageViewContainerNode.backgroundColor = .red
        imageViewNode.backgroundColor = .green
        
        imageViewNode.sharedCallback = { [weak self] in
            guard let strongSelf = self else { return }
            guard let combinedSpectra = strongSelf.lastSpectra else { return }
            let maxValue = combinedSpectra.max() ?? 1.0
            DispatchQueue.main.async {
                for index in stride(from: 0, to: combinedSpectra.count, by: 1) {
                    let value = combinedSpectra[index]
                    let normalizedValue = CGFloat(value) / CGFloat(maxValue)
                    let height = strongSelf.minimumBarHeight + normalizedValue * (strongSelf.maximumBarHeight - strongSelf.minimumBarHeight)
                    strongSelf.updateSpectrumLayer(at: index, height: height)
                    strongSelf.hasNewData = false
                }
            }
        }
    }
    

    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let imageSize = CGSize(width: albumWidth, height: albumWidth)

        imageViewNode.style.preferredSize = imageSize
        imageViewNode.clipsToBounds = true
        imageViewNode.borderColor = UIColor.white.cgColor
        imageViewNode.borderWidth = 5
        imageViewNode.cornerRadius = imageSize.width / 2

        let imageNodeSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imageViewNode)

        imageViewContainerNode.style.preferredSize = imageSize
        imageViewContainerNode.cornerRadius = imageSize.width / 2
        imageViewContainerNode.backgroundColor = .red
        imageViewContainerNode.layoutSpecBlock = { (_, _) in
            return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imageNodeSpec)
        }

        let insetSpec = ASInsetLayoutSpec(insets: .zero, child: imageViewContainerNode)
        let centerLayoutSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: insetSpec)

        return centerLayoutSpec
    }
    
    open override func didLoad() {
        super.didLoad()
        imageViewContainerNode.addSubnode(imageViewNode)
    }
    
    public func updateSpectrum(with spectra: [Float]) {
        guard SpectrumView.isEnable else { return }
        
        let now = DispatchTime.now()
          let minInterval = DispatchTimeInterval.milliseconds(100)  // 设置最小更新间隔为 100 毫秒
          if now < lastUpdateTime + minInterval {
              // 如果距离上次更新的时间还不足最小间隔，那么就跳过这次更新
              print(".skip")
              return
          }
        lastUpdateTime = now

        
        DispatchQueue.global(qos: .userInitiated).async {
            let numberOfBars = self.computeNumberOfBars()
            SpectrumView.barNumbers = numberOfBars
            
            let halfBars = numberOfBars / 2
            let halfSpectra = Array(spectra.prefix(halfBars))
            
            var combinedSpectra = halfSpectra + halfSpectra
            let maxValue = combinedSpectra.max() ?? 1.0
            
            let barCount = 8
            let maxIndex = min(barCount, combinedSpectra.count)
            for i in 0..<maxIndex {
                let progress = Float(i) / Float(barCount)
                combinedSpectra[i] *= progress
                combinedSpectra[combinedSpectra.count - 1 - i] *= progress
                
                combinedSpectra[halfBars - 1 - i] *= progress
                combinedSpectra[halfBars + i] *= progress
                combinedSpectra[halfBars * 2 - 1 - i] *= progress
            }
            
            self.lastSpectra = combinedSpectra
            self.hasNewData = true
        }
    }
    
    private func updateSpectrumLayer(at index: Int, height: CGFloat) {
        if    height.isNaN || index >= spectrumLayers.count {
            return
        }
        let layer = spectrumLayers[index]
        let angle = spectrumAngles[index]
        
        let radius = ( albumWidth + SpectrumView.barSpacing * 2) / 2
        let path = UIBezierPath()
        let startPoint = CGPoint(x: bounds.midX + cos(angle) * radius,
                                 y: bounds.midY + sin(angle) * radius)
        path.move(to: startPoint)
        path.addLine(to: CGPoint(x: startPoint.x + cos(angle) * height,
                                 y: startPoint.y + sin(angle) * height))
        layer.path = path.cgPath
    }
    
    private func configureSpectrumLayers() {
        spectrumLayers.removeAll()
        spectrumAngles.removeAll()
        
        let numberOfBars = computeNumberOfBars()
        let angleIncrement = SpectrumView.totalDegrees / CGFloat(numberOfBars) * CGFloat.pi / 180
        var currentAngle: CGFloat = -CGFloat.pi
        
        for index in 0..<numberOfBars {
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            
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
            
//            shapeLayer.shadowColor = baseColor.cgColor
//            shapeLayer.shadowOffset = CGSize(width: 0, height: 1)
//            shapeLayer.shadowRadius = 3
//            shapeLayer.shadowOpacity = 0.7
//
            shapeLayer.lineWidth = SpectrumView.barWidth
            shapeLayer.lineCap = .round
            shapeLayer.shouldRasterize = true
            shapeLayer.drawsAsynchronously = true
            
            layer.addSublayer(shapeLayer)
            spectrumLayers.append(shapeLayer)
            spectrumAngles.append(currentAngle)
            currentAngle += angleIncrement
        }
    }
    
    private func computeNumberOfBars() -> Int {
        let circleCircumference = (albumWidth + SpectrumView.barSpacing * 2) * CGFloat.pi
        let totalBarWidth = SpectrumView.barWidth + SpectrumView.barSpacing
        let numberOfBars = Int(circleCircumference / totalBarWidth)
        let numberBands = numberOfBars + (circleCircumference.truncatingRemainder(dividingBy: totalBarWidth) > 0 ? 1 : 0)
        AudioAnalyzer.drawBands = numberBands
        
        return numberBands
    }
    
}
