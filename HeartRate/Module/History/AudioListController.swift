//
//  AudioListTableViewController.swift
//  HeartRate
//
//  Created by kaoji on 4/12/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import UIKit

class AudioListTableViewController: UITableViewController {
    
    
    var audios: [AudioEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "历史录制"
        view.backgroundColor = .black
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        loadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearTempDirectory()
    }

    func loadData() {
        audios = PersistManager.shared.fetchAllAudios()
        tableView.reloadData()
    }

    // UITableViewDataSource methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let audio = audios[indexPath.row]
        cell.textLabel?.text = audio.name
        return cell
    }

    // Swipe actions

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let audio = self.audios[indexPath.section]
            
            // 删除
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsDirectory.appendingPathComponent(audio.name!)//移除音频
            PersistManager.shared.deleteAudio(audioEntity: audio)//移除数据库
            self.audios.removeAll(where: { $0.name == audio.name })//当前列表数据源
            tableView.reloadData()//刷新列表
            completionHandler(true)
        }

        let shareAction = UIContextualAction(style: .normal, title: "导出") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            // 打包数据分享
            let audio = self.audios[indexPath.section]
            if let topController = UIApplication.topViewController() {
                BPMExporter.exportAndShare(audioEntity: audio, viewController: topController)
            }
           
            
            completionHandler(true)
        }

        shareAction.backgroundColor = .systemBlue

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return swipeActions
    }
    
    func clearTempDirectory() {
        let fileManager = FileManager.default
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            print("Successfully cleared the temp directory.")
        } catch {
            print("Error while clearing temp directory: \(error)")
        }
    }
}
