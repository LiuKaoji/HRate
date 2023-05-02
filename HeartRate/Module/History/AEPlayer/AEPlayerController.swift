//
//  AEPlayerController.swift
//  HRate
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
class AEPlayerController: UIViewController {

    private var viewModel = AudioPlayerViewModel()
    private let disposeBag = DisposeBag()

    private lazy var playerView = AEPlayerView()
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.addSubview(playerView)
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setupBindings()
        playListAction()
    }
    
    func playListAction(){
        
        viewModel.showAudioList = { [weak self] in
            guard let strongSelf  = self else { return }
            let playList = PlayListViewController.init(viewModel: strongSelf.viewModel)
            playList.show()
        }
    }

    private func setupBindings() {
        // 播放暂停按钮
        playerView.controlsView.playPauseButton.rx.tap
            .bind(to: viewModel.playPauseButtonTapped)
            .disposed(by: disposeBag)
        
        // 上一首按钮
        playerView.controlsView.prevButton.rx.tap
            .bind(to: viewModel.previousButtonTapped)
            .disposed(by: disposeBag)
        
        // 下一首按钮
        playerView.controlsView.nextButton.rx.tap
            .bind(to: viewModel.nextButtonTapped)
            .disposed(by: disposeBag)
        
        // 循环按钮
        playerView.controlsView.loopButton.rx.tap
            .bind(to: viewModel.loopButtonTapped)
            .disposed(by: disposeBag)
        
        // 播放列表按钮
        playerView.controlsView.playlistButton.rx.tap
            .bind(to: viewModel.playlistButtonTapped)
            .disposed(by: disposeBag)
        
        // 播放进度滑块
        playerView.controlsView.slider.rx.value
            .bind(to: viewModel.sliderValueChanged)
            .disposed(by: disposeBag)
        
        // ViewModel -> View
        viewModel.title.asDriver()
            .drive(playerView.albumInfoView.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.fileInfo.asDriver()
            .drive(playerView.albumInfoView.infoLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentTime.asDriver()
            .drive(playerView.controlsView.currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.totalTime.asDriver()
            .drive(playerView.controlsView.totalTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        viewModel.fftData.asDriver()
            .drive(playerView.albumInfoView.albumView.rx.spectrum)
            .disposed(by: disposeBag)
        
        viewModel.chartBPMData.asDriver()
            .drive(playerView.chartView.chart.rx.data)
            .disposed(by: disposeBag)
        
        viewModel.bpmInfo.asDriver()
            .drive(playerView.chartView.bpmLable.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.progress.asDriver()
            .drive(playerView.controlsView.slider.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.playPauseImage.asDriver()
            .drive(onNext: { [weak self] image in
                self?.playerView.controlsView.playPauseButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        
        
        viewModel.isRotating.asDriver()
            .drive(onNext: { [weak self] isRotating in
                if isRotating {
                    self?.playerView.albumInfoView.albumView.imageView.startRotate()
                } else {
                    self?.playerView.albumInfoView.albumView.imageView.pauseRotate()
                }
            })
            .disposed(by: disposeBag)
        
        
        playerView.backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.stopAndReleaseMemory()
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        playerView.shareButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, self.viewModel.audioEntities.value.count > 0  else { return }
                let audio  = self.viewModel.audioEntities.value[self.viewModel.currentIndex.value]
                BPMExporter.exportAndShare(audioEntity: audio, viewController: self)
                
            })
            .disposed(by: disposeBag)
    }
}
