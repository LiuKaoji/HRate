//
//  AudioListTableViewController.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SnapKit

class AudioListTableViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{.lightContent}
    private let tableView = UITableView.init(frame: .zero, style: .insetGrouped)
    let indicatorBarButton = PlaybackIndicator()
    private var headerView: LineChartHeaderView!
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        viewModel.musicPlayer.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHeaderView()
        bindViewModel()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        self.navigationController?.navigationBar.barStyle = .black
        self.title = "录制历史"
        tableView.backgroundColor = StyleConfig.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints({ $0.top.left.bottom.right.equalToSuperview() })
        tableView.contentInset = UIEdgeInsets(top: viewModel.headerHeight.value, left: 0, bottom: 0, right: 0)
        tableView.register(AudioCell.self, forCellReuseIdentifier: "AudioCell")
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let backImage = UIImage.init(named: "backLight")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = .init(image: backImage, style: .plain, target: self, action: #selector(onClickBack))
        self.navigationItem.rightBarButtonItem = indicatorBarButton
        
        // 增加一个无数据记录占位
        let noDataLabel = UILabel()
        noDataLabel.text = "暂无录制文件"
        noDataLabel.textColor = UIColor.gray
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 18)
        noDataLabel.textAlignment = .center
        view.addSubview(noDataLabel)
        noDataLabel.snp.makeConstraints({ $0.center.equalToSuperview() })

        viewModel.audioEntities
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self, weak noDataLabel] isEmpty in
                self?.tableView.isHidden = isEmpty
                noDataLabel?.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)
        
        selectFirstRow()
    }
    
    @objc func onClickBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupHeaderView() {
        let initialHeaderHeight = viewModel.headerHeight.value
        headerView = LineChartHeaderView(height: initialHeaderHeight)
        tableView.tableHeaderView = headerView
    }
    
    private func bindViewModel() {
        viewModel.headerHeight
            .asDriver()
            .drive(onNext: { [weak self] height in
                self?.headerView.updateHeight(height)
            })
            .disposed(by: disposeBag)
        
        viewModel.audioEntities
            .bind(to: tableView.rx.items(cellIdentifier: "AudioCell", cellType: AudioCell.self)) { (row, element, cell) in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.chartBPMData.bind(to: self.headerView.chart.rx.data).disposed(by: disposeBag)// 更新图表
        viewModel.playTime?.bind(to: self.headerView.durationLabel.rx.text).disposed(by: disposeBag)// 更新播放时长
        viewModel.bpmStatus?.bind(to: self.headerView.bpmLable.rx.text).disposed(by: disposeBag)//更新心率
        viewModel.indicateState?.bind(to: self.indicatorBarButton.rx.state).disposed(by: disposeBag)//绑定音频指示器转态
        
    }
    
    func selectFirstRow(){
        // 选中第一行
        DispatchQueue.main.async { [self] in
            let firstIndexPath = IndexPath(row: 0, section: 0)
            if viewModel.audioEntities.value.count > 0 {
                let audioEntity = viewModel.audioEntities.value[firstIndexPath.row]
                viewModel.playMusic(with: audioEntity)
                tableView.selectRow(at: firstIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }
}

extension AudioListTableViewController: UITableViewDelegate {
    
    // 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //选中播放
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioEntity = viewModel.audioEntities.value[indexPath.row]
        viewModel.playMusic(with: audioEntity)
    }
    
    // 侧滑选项
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completionHandler in
               guard let self = self else { return }
               let audio = viewModel.audioEntities.value[indexPath.row]
               let isSelected = (audio == viewModel.audioEntity)
               viewModel.deleteEntity(with: audio)
               isSelected ?selectFirstRow():nil
               completionHandler(true)
           }

           let shareAction = UIContextualAction(style: .normal, title: "导出") { [weak self] _, _, completionHandler in
               guard let self = self else { return }
               // 打包数据分享
               let audio = viewModel.audioEntities.value[indexPath.row]
               if let topController = UIApplication.topViewController() {
                   BPMExporter.exportAndShare(audioEntity: audio, viewController: topController)
               }
               completionHandler(true)
           }

           shareAction.backgroundColor = .systemBlue

           let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
           return swipeActions
       }
}
