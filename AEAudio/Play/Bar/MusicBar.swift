//
//  AudioBar.swift
//  AEAudio
//
//  Created by kaoji on 4/28/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit

public enum AudioBarState: Int {
    case stopped, playing, paused
}

class BarContent: UIView {
    private let bars: [CALayer]
    
    override init(frame: CGRect) {
        bars = (0..<3).map { i in
            let bar = CALayer()
            bar.bounds.size = CGSize(width: 3, height: CGFloat(i + 1) * 12 / 3)
            bar.position.x = CGFloat(i) * (3 + (UIScreen.main.scale == 2 ? 1.5 : 2))
            bar.position.y = 12
            bar.anchorPoint.y = 1
            return bar
        }
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        bars.forEach { layer.addSublayer($0) }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func tintColorDidChange() { bars.forEach { $0.backgroundColor = tintColor.cgColor } }
    override var intrinsicContentSize: CGSize {
        let unionFrame = bars.map { $0.frame }.reduce(CGRect.zero, { $0.union($1) })
        return unionFrame.size
    }
    
    func startAnimating() {
        guard !isAnimating() else { return }
        bars.forEach { bar in
            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.fromValue = 3
            animation.toValue = 6 + CGFloat(arc4random_uniform(7))
            animation.duration = 0.3 * Double(arc4random_uniform(3) + 1)
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            bar.add(animation, forKey: "animation")
        }
    }
    
    func stopAnimating() {
        guard isAnimating() else { return }
        bars.forEach { $0.removeAnimation(forKey: "animation") }
    }
    
    func isAnimating() -> Bool {
        return bars.first?.animation(forKey: "animation") != nil
    }
}


@objc open class AudioBar: UIView {
    @objc open var hidesWhenStopped = true {
        didSet { isHidden = state == .stopped && hidesWhenStopped }
    }
    
    public var state: AudioBarState = .stopped {
        didSet {
            state == .stopped ? stopAnimating() : (state == .playing ? startAnimating() : stopAnimating())
            isHidden = state == .stopped && hidesWhenStopped
        }
    }
    
    private var contentView: BarContent!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        contentView = BarContent()
        addSubview(contentView)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnterBackground() { stopAnimating() }
    @objc private func applicationWillEnterForeground() { if state == .playing { startAnimating() } }
    
    private func startAnimating() { contentView.startAnimating() }
    private func stopAnimating() { contentView.stopAnimating() }
}
