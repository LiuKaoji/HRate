//
//  PlayController.swift
//  HRTune
//
//  Created by kaoji on 4/25/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation

class PlayController: UIViewController,AutoMemoryTracking {

    private var viewModel = PlayViewModel()
    private var disposeBag = DisposeBag()
    private lazy var playView = PlayView()
    private lazy var playList: PlayListController? = .init(viewModel)
    
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
        view.addSubview(playView)
        playView.frame = view.bounds
        playView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setupBindings()
        playListAction()
        showPlayList()
        
//        playList?.titleHandle = {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                self.updateTitle()
//            })
//        }
    }
    
    func playListAction(){
        viewModel.showAudioList = { [weak self] in
            self?.showPlayList()
        }
    }
    
    func showPlayList(){
        if let playList = self.playList {
            self.present(playList, animated: true)
        }
    }

    private func setupBindings() {
        // 播放暂停按钮
        playView.controlsView.playPauseButton.rxTapClosure()
            .bind(to: viewModel.togglePlay)
            .disposed(by: disposeBag)
        
        // 上一首按钮
        playView.controlsView.prevButton.rxTapClosure()
            .bind(to: viewModel.toggleBack)
            .disposed(by: disposeBag)
        
        // 下一首按钮
        playView.controlsView.nextButton.rxTapClosure()
            .bind(to: viewModel.toggleForward)
            .disposed(by: disposeBag)
        
        // 循环按钮
        playView.controlsView.loopButton.rxTapClosure()
            .bind(to: viewModel.toggleMode)
            .disposed(by: disposeBag)
        
        // 播放列表按钮
        playView.controlsView.playlistButton.rxTapClosure()
            .bind(to: viewModel.toggleList)
            .disposed(by: disposeBag)
        
        // 播放进度滑块
        playView.controlsView.slider.rx.value
            .bind(to: viewModel.sliderChanged)
            .disposed(by: disposeBag)
        
        playView.controlsView.slider.rx.controlEvent(.touchDown)
            .bind(to: viewModel.sliderDown)
            .disposed(by: disposeBag)
        
        playView.controlsView.slider.rx.controlEvent(.touchUpOutside)
            .bind(to: viewModel.sliderOutside)
            .disposed(by: disposeBag)

        playView.controlsView.slider.rx.controlEvent(.touchCancel)
            .bind(to: viewModel.sliderCancel)
            .disposed(by: disposeBag)
        
        
        playView.controlsView.slider.rx.controlEvent(.touchUpInside)
            .bind(to: viewModel.sliderInside)
            .disposed(by: disposeBag)
        
        
        // ViewModel -> View
        viewModel.outTitle.asDriver()
            .drive(playView.albumInfoView.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outFileDesc.asDriver()
            .drive(playView.albumInfoView.infoLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outCoverImage.asDriver()
            .drive(playView.albumInfoView.albumView.imageNode.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outCoverImage.asDriver()
            .drive(playView.bgImgView.rx.image)
            .disposed(by: disposeBag)
        
        
        viewModel.outNowTime.asDriver()
            .drive(playView.controlsView.currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outDuration.asDriver()
            .drive(playView.controlsView.totalTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        viewModel.outfftData.asDriver()
            .drive(playView.albumInfoView.specView.rx.spectrum)
            .disposed(by: disposeBag)
        
        viewModel.outChartData.asDriver()
            .drive(playView.chartView.chart.rx.data)
            .disposed(by: disposeBag)
        
        viewModel.outBpmDesc.asDriver()
            .drive(playView.chartView.bpmLable.rx.hiddenText)
            .disposed(by: disposeBag)
        
        viewModel.progress.asDriver()
            .drive(playView.controlsView.slider.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.outModeImage.asDriver()
            .drive(onNext: { [weak self] image in
                self?.playView.controlsView.loopButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        
        
        viewModel.outIsRotating.asDriver()
            .drive(onNext: { [weak self] isRotating in
                if isRotating {
                    self?.playView.albumInfoView.albumView.imageNode.startRotate()
                    self?.playView.controlsView.playPauseButton.isSelected = true
                } else {
                    self?.playView.albumInfoView.albumView.imageNode.pauseRotate()
                    self?.playView.controlsView.playPauseButton.isSelected = false
                }
            })
            .disposed(by: disposeBag)
        
        
        playView.backButton.rxTapClosure()
            .subscribe(onNext: { [weak self]  in
                self?.viewModel.stopAndReleaseMemory()
                self?.disposeBag = DisposeBag()
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        playView.shareButton.rxTapClosure()
            .subscribe(onNext: { [weak self]  in
                guard let self = self else { return }
             
                if let audio = self.viewModel.playListData.value[self.viewModel.currentIndex.value] as? MusicInfo,
                    let audioURL = audio.audioURL() {
                    ShareExporter.shareFilesWithAirDrop(fileURL: audioURL, viewController: self)
                }
                else if let audio = self.viewModel.playListData.value[self.viewModel.currentIndex.value] as? AudioEntity {
                    ShareExporter.exportAndShare(audioEntity: audio, viewController: self)
                }
            })
            .disposed(by: disposeBag)

    }
    
//    func updateTitle(){
//        let defaultIndex = Constants.shared.defaultPlaylistIndex
//        switch defaultIndex {
//        case 0:
//            // 已录制
//            self.playView.playTitle.text = "已录制"
//        case 1:
//            // 我的自定义音频
//            self.playView.playTitle.text = "音频包"
//        case 2:
//            // 收藏夹
//            self.playView.playTitle.text = "收藏夹"
//        default:
//            self.playView.playTitle.text = "HRTune"
//        }
//    }
    
    deinit {
        self.prepareForDeinit()
        playList = nil
    }
}
