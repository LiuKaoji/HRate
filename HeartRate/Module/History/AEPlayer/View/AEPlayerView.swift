import Foundation
import UIKit
import SnapKit

class AEPlayerView: UIView {
    
    private let bgImgView = createBgImgView()
    private let visualEffectView = createVisualEffectView()
    public let backButton = createBackButton()
    public let shareButton = createShareButton()
    public let albumInfoView = AlbumInfoView()
    public let controlsView = PlayerControlsView()
    public let chartView = AEChartView(height: 400)
    
    private lazy var parallaxScrollView: ParallaxScrollView = {
        let items = [
            HorizontalParallaxScrollViewItem(view: albumInfoView,
                                             acceleration: .invariable(CGPoint(x: 1, y: 0))),
            HorizontalParallaxScrollViewItem(view: chartView,
                                             acceleration: .invariable(CGPoint(x: 0.5, y: 0)))
        ]
        let scrollView = ParallaxScrollView(frame: .zero, items: items)
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(bgImgView)
        addSubview(visualEffectView)
        addSubview(parallaxScrollView)
        addSubview(controlsView)
        addSubview(backButton)
        addSubview(shareButton)
        
    
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        controlsView.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalToSuperview().inset(30)
        }
        
        parallaxScrollView.snp.makeConstraints { make in
            make.top.left.width.equalToSuperview()
            make.bottom.equalTo(controlsView.snp.top)
        }
        
        albumInfoView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.left.top.bottom.equalTo(parallaxScrollView)
        }
        
        chartView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(10)
            make.width.height.equalTo(44)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalTo(safeAreaLayoutGuide.snp.right).offset(-10)
            make.width.height.equalTo(44)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.parallaxScrollView.updateParallaxLayout()
        })
    }
    
    private static func createBackButton() -> UIButton {
        let backButton = UIButton(type: .system)
        backButton.setImage(R.image.backLight()!, for: .normal)
        backButton.tintColor = .white
        return backButton
    }
    
    private static func createShareButton() -> UIButton {
          let shareButton = UIButton(type: .system)
          shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
          shareButton.tintColor = .white
          return shareButton
      }
    
    private static func createBgImgView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.image = R.image.backgroundJpg()
        return imageView
    }
    
    private static func createVisualEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        return visualEffectView
    }
    
}
