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
    var audiosWithBPMs: [AudioEntity: [BPMEntity]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        loadData()
    }

    func loadData() {
        audiosWithBPMs = PersistManager.shared.fetchAllAudiosWithBPMs()
        tableView.reloadData()
    }

    // UITableViewDataSource methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audiosWithBPMs.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let audio = Array(audiosWithBPMs.keys)[indexPath.row]
        cell.textLabel?.text = audio.name
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Audio List"
    }

    // Swipe actions

//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
//            let audio = Array(self.audiosWithBPMs.keys)[indexPath.section]
//            
//            // delete
//            PersistManager.shared.deleteAudio(audioEntity: audio)
//            if let bpms = self.audiosWithBPMs[audio] {
//                bpms.forEach { bpm in
//                    PersistManager.shared.deleteBPM(bpmEntity: bpm)
//                }
//            }
//            completionHandler(true)
//        }
//
//        let shareAction = UIContextualAction(style: .normal, title: "Share") { _, _, completionHandler in
//            let audio = Array(self.audiosWithBPMs.keys)[indexPath.section]
//            if let bpm = self.audiosWithBPMs[audio]?[indexPath.row] {
//                let textToShare = "BPM: \(bpm.bpm), Timestamp: \(bpm.ts)"
//                let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
//                self.present(activityViewController, animated: true, completion: nil)
//            }
//            completionHandler(true)
//        }
//
//        shareAction.backgroundColor = .systemBlue
//
//        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
//        return swipeActions
//    }
}
