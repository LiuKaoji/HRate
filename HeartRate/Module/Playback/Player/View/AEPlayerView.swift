import Foundation
import UIKit
import SnapKit
import AEAudio

class AEPlayerView: UIView {
    
    public let bgImgView = createBgImgView()
    private let visualEffectView = createVisualEffectView()
    public let backButton = createBackButton()
    public let shareButton = createShareButton()
    public let albumInfoView = AlbumInfoView()
    public let controlsView = PlayerControlsView()
    public let chartView = AEChartView(frame: .zero)
    lazy var playTitle: UILabel = UILabel()
    
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
        
        playTitle.text = "HRate"
        playTitle.textColor = UIColor.init(white: 1.0, alpha: 0.8)
        playTitle.font = .boldSystemFont(ofSize: 18)
        playTitle.textAlignment = .center
        
        addSubview(bgImgView)
        addSubview(visualEffectView)
        addSubview(parallaxScrollView)
        addSubview(controlsView)
        addSubview(backButton)
        addSubview(shareButton)
        addSubview(playTitle)
    
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
            make.left.top.equalTo(parallaxScrollView)
            make.bottom.equalTo(controlsView.snp.top).offset(-16)
        }
        
        chartView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.left.top.equalTo(parallaxScrollView)
            make.bottom.equalTo(controlsView.snp.top).offset(-16)
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
        
        playTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton.snp.centerY)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
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
        imageView.image = R.image.cover()
        return imageView
    }
    
    private static func createVisualEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        return visualEffectView
    }
    
}
