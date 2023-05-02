//
//  PlayListView.swift
//  HRate
//
//  Created by kaoji on 4/26/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import AEAudio
class PlayListView: UIView, UITableViewDelegate {
    private var backgroundView: UIView!
    private var containerView: UIView!
    private var tableView: UITableView!
    private var footerView: UIView!
    private var closeButton: UIButton!
    private var headerView: PlayListHeader!
    private var visualEffectView: UIVisualEffectView!
    private var footLine: UIView!
    private var headLine: UIView!
    private let viewModel: AudioPlayerViewModel!
    private let disposeBag = DisposeBag()

    init(viewModel: AudioPlayerViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
        setupTableView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        self.viewModel = AudioPlayerViewModel()
        super.init(coder: coder)
    }

    private func setupUI() {
        
        //点击空白处关闭
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(hide))
        
        // Background view
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        backgroundView.frame = UIScreen.main.bounds
        addSubview(backgroundView)
        backgroundView.addGestureRecognizer(tapG)
        
        // Container view
        containerView = UIView()
        containerView.backgroundColor = .clear
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        // Add visual effect view for blur effect
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        containerView.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Header view
        headerView = PlayListHeader()
        containerView.addSubview(headerView)
        headerView.configure(fileCount: 0, description: "音频与心率及消耗关联.")
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        headLine = UIView()
        headLine.backgroundColor = UIColor.init(white: 1.0, alpha: 0.2)
        headerView.addSubview(headLine)
        headLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // Footer view
        footerView = UIView()
        footerView.backgroundColor = .clear
        containerView.addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        
        footLine = UIView()
        footLine.backgroundColor = UIColor.init(white: 1.0, alpha: 0.2)
        footerView.addSubview(footLine)
        footLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        footerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.top.equalToSuperview()
        }
        
        self.layoutIfNeeded()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.init(white: 1.0, alpha: 0.2)
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        //tableView.contentInset = UIEdgeInsets(top: viewModel.headerHeight.value, left: 0, bottom: 0, right: 0)
        tableView.register(AudioCell.self, forCellReuseIdentifier: "AudioCell")
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        
        viewModel.audioEntities
            .bind(to: tableView.rx.items(cellIdentifier: "AudioCell", cellType: AudioCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                cell.configure(with: element, isPlaying: (row == self.viewModel.currentIndex.value))
                cell.updateMusicIndicator(isPlaying: (row == self.viewModel.currentIndex.value))
            }
            .disposed(by: disposeBag)
        
        viewModel.audioEntities
               .subscribe(onNext: { [weak self] audioEntities in
                   guard let self = self else { return }
                   self.headerView.configure(fileCount: audioEntities.count, description: "音频与心率及消耗关联.")
               })
               .disposed(by: disposeBag)
        
        viewModel.audioEntities
                .subscribe(onNext: { [weak self] audioEntities in
                    guard let self = self else { return }
                    self.headerView.configure(fileCount: audioEntities.count, description: "音频与心率及消耗关联.")
                    
                    // Show empty label when there are no files
                    if audioEntities.count == 0 {
                        self.tableView.setEmptyStateViewVisible(true)
                        tableView.separatorStyle = .none
                    } else {
                        self.tableView.setEmptyStateViewVisible(false)
                        tableView.separatorStyle = .singleLine
                    }
                })
                .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.playAudioEntity(viewModel.audioEntities.value[indexPath.row])
        tableView.reloadData()
    }
    
    @objc private func closeButtonTapped() {
        hide()
    }
    
   @objc func show() {
        SpectrumView.isEnable = false
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        window.addSubview(self)
        self.frame = window.bounds
        
        self.backgroundView.alpha = 0
        let height = self.containerView.bounds.height
        self.containerView.transform = CGAffineTransform(translationX: 0, y: height)
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
            let height = self.containerView.bounds.height
            self.containerView.transform = CGAffineTransform(translationX: 0, y: height)
        }) { _ in
            self.removeFromSuperview()
            SpectrumView.isEnable = true
        }
    }
}
