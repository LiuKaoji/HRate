//
//  PlayListController.swift
//  HRTune
//
//  Created by kaoji on 5/13/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit

class PlayListController: UIViewController {
    
    let disposeBag = DisposeBag()
    var listView = R.nib.playList.firstView(owner: nil)!
    weak var vm: PlayViewModel!
    var titleHandle: (()->())?

    convenience init(_ vm: PlayViewModel) {
        self.init()
        self.vm = vm
        bindViewModel(vm)
    }

    override func loadView() {
        super.loadView()
        self.view = listView
        listView.tableView.delegate = self
        setupStripesPagingView()
        updateDefaultListButtonColor()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCurrent()
    }
    
    deinit {
        print("PlayListController deinit")
    }

    private func setupStripesPagingView() {
        listView.stripesPagingView.delegate = self
        listView.switchToPage(index: Constants.shared.defaultPlaylistIndex)
    }

    func bindViewModel(_ vm: PlayViewModel){
        guard let tableView = listView.tableView else { return }
        
        // 数据源绑定
        vm.playListData.bind(to: tableView.rx.items(cellIdentifier: "PlayListCell", cellType: PlayListCell.self))
        {(row, element, cell) in
            let playable = element
            let isPlaying = (vm.currentIndex.value == row)
            cell.configure(with: playable)
            cell.setMusicIndicatorState((isPlaying ?.playing:.stopped))
        }
        .disposed(by: disposeBag)
        
        
        // 文件占位图
        vm.playListData.subscribe(onNext: { [weak tableView] playListData in
            let isEmpty = playListData.isEmpty
            tableView?.setEmptyStateViewVisible(isEmpty)
            tableView?.separatorStyle = isEmpty ? .none : .singleLine
        }).disposed(by: disposeBag)
        
        //播放索引更新
        vm.currentIndex.subscribe { [weak self] index in
            guard let strongSelf = self, tableView.numberOfSections > 0 else { return }
            let numberOfRows = tableView.numberOfRows(inSection: 0)
            if let indexPath = numberOfRows > index ? IndexPath(row: index, section: 0) : nil {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                strongSelf.listView.countLabel.text = "\(index+1) / \(vm.playListData.value.count)"
            }
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            
        }.disposed(by: disposeBag)

        
        // 更新封面背景
        vm.outCoverImage.delay(.milliseconds(200), scheduler: MainScheduler.instance).subscribe { [weak self] image in
            self?.listView.updatePageInfoImage(image: image)
        }.disposed(by: disposeBag)
        
        // 设为默认
        listView.defaultListButton.rx.tap.subscribe {_ in self.defaultListButtonTapped()}
        .disposed(by: disposeBag)
        
        // 返回
        listView.btnNextAction.rx.tap.subscribe { [weak self] _ in
            self?.dismiss(animated: true)
        }
        .disposed(by: disposeBag)
        
        // 订阅 isRotating 的变化
        vm.outIsRotating.delay(.milliseconds(100), scheduler: MainScheduler.instance).subscribe { isRotating in
            let indexPath = IndexPath(row: vm.currentIndex.value, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? PlayListCell {
                cell.setMusicIndicatorState(isRotating ? .playing : .paused)
            }
        }.disposed(by: disposeBag)

    }
    
    fileprivate func configureSimpleSearchTextField() {
        listView.searchTF.filterStrings(vm.playListData.value.compactMap { $0.audioName() })
        listView.searchTF.itemSelectionHandler = { [weak self] filteredResults, itemPosition in
            guard let self = self else { return }
            let str = filteredResults[itemPosition].title
            if let index = self.vm.playListData.value.firstIndex(where: { $0.audioName() == str }) {
                self.vm.playAudioEntity(index, self.vm.playListData.value[index])
                self.listView.searchTF.text = ""
                self.listView.tableView.reloadData()
                self.view.endEditing(true)
            }
        }
    }
    
    func scrollToCurrent() {
        guard let tableView = listView.tableView else { return }
        tableView.reloadData()
        
        let numberOfSections = tableView.numberOfSections
        let index = vm.currentIndex.value
        
        if numberOfSections > 0, tableView.numberOfRows(inSection: 0) > index {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
}

extension PlayListController: PagingViewDelegate{
    
    // 0 为录音历史 1为音乐包数据源 2位收藏夹
    func pagingView(_ pagingView: PagingView, didSelectPageAtIndex index: Int) {
        switch index {
        case 0: vm.switchToRecordedList()
        case 1: vm.switchToAudioPackageList()
        case 2: vm.switchToCollectionList()
        default: break
        }
        listView.updatePageInfo(index: index)
        configureSimpleSearchTextField()
        updateDefaultListButtonColor()
        self.titleHandle?()
    }
    
    func updateDefaultListButtonColor() {
        let defaultIndex = Constants.shared.defaultPlaylistIndex
        listView.defaultListButton.tintColor = (defaultIndex == listView.stripesPagingView.selected) ? .yellow : .lightGray
    }

    func defaultListButtonTapped() {
        let currentPage = listView.stripesPagingView.selected
        if Constants.shared.defaultPlaylistIndex != currentPage {
            Constants.shared.defaultPlaylistIndex = currentPage
            updateDefaultListButtonColor()
        }
    }
}

extension PlayListController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        vm.playAudioEntity(indexPath.row, vm.playListData.value[indexPath.row])
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let playable = self.vm.playListData.value[indexPath.row]
        let isFavor = playable.isMarkFavor()
        
        var actions: [UIContextualAction] = []
        
        if listView.stripesPagingView.selected == 0 {
            let deleteTitle = "删除"
            let deleteAction = UIContextualAction(style: .normal, title: deleteTitle) { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }
                UIAlertController.presentAlert(on: self, title: "确认删除文件", message: "删除后不可恢复，请谨慎操作！", confirmButtonTitle: deleteTitle, cancelButtonTitle: "取消", confirmHandler: {
                    self.vm.removeAudioEntity(at: indexPath.row)
                    tableView.reloadData()
                    completionHandler(true)
                }, cancelHandler: nil)
            }
            actions.append(deleteAction)
        }
        
        let title = isFavor ? "取消收藏" : "收藏"
        let favorAction = UIContextualAction(style: .destructive, title: title) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            if isFavor {
                playable.unMarkFavor()
            } else {
                playable.markFavor()
            }
            HRToast(message: "已\(title)", type: .success)
            if self.listView.stripesPagingView.selected == 2 {
                self.vm.removeCollection(at: indexPath.row)
            }
            completionHandler(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                tableView.reloadData()
            }
        }
        actions.append(favorAction)
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
