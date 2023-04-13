//
//  RecordController.swift
//  HeartRate
//
//  Created by kaoji on 4/9/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation
import UIKit
import Charts

class RecordController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        .lightContent
    }
    
    var audioModel: AudioEntity? // 音频录制实体
    var bpmModels: [BPMEntity] = [] // 关联的心率
    
    var recordView: RecordView! // 视图
    var tracker = HeartRateTracker.shared // 心率计算器
    var rec: Recorder = Recorder()//录音机
    
    override func loadView() {
        super.loadView()
        recordView = RecordView.init(frame: self.view.frame)
        self.view = recordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordView.recordButton.addTarget(self, action: #selector(onClickRecordButton), for: .touchUpInside)
        recordView.historyButton.addTarget(self, action: #selector(onClickHistoryButton), for: .touchUpInside)
        
        dataHandle()
    }
    
    @objc func onClickHistoryButton(){
        self.present(AudioListTableViewController(), animated: true)
    }
    
    @objc func onClickRecordButton(){
        
        // 开始录制
        if recordView.recordButton.buttonState == .normal {
            tracker.state = .launching
            tracker.startWatchApp { [weak self] error in
                if let error = error {
                    self?.tracker.state = .errorOccur(error)
                }else{
                    self?.startRec()
                }
            }
        }
        
        //停止录制
        else {
            tracker.state = .notStarted
            
            guard let wcManager = WatchConnectivityManager.shared else { return }
            
            wcManager.fetchReachableState { isReachable in
                if isReachable {
                    wcManager.send([.workoutStop : true])
                } else {
                    wcManager.transfer([.workoutStop : true])
                }
            }
            self.stopRec()
        }
    }
    
    // 开始录制声音及处理心跳
    func startRec(){
        self.newAudioEntity()
        self.rec.startRecording()
        self.recordView.recordUI()
    }
    
    // 停止录制声音及处理心跳
    func stopRec(){
        
        self.recordView.resetUI()
        self.rec.stopRecording()
    }
    
    // 新增数据库实体 音频
    func newAudioEntity(){
        let dateStr = CTZDateFormatter.shared.currentDateString()
        let name = "\(dateStr)"
        
        audioModel = AudioEntity()
        audioModel?.date = dateStr
        audioModel?.name = name
        audioModel?.ext = "m4a"
        audioModel?.audioId = UUID().uuidString
    }
    
    // 新增数据库实体 心跳
    func newBPMEntity(nowBPM: Int16, date: String, ts: TimeInterval){
        guard let audio = self.audioModel else { return }
        let bpm = BPMEntity()
        bpm.audioId = audio.audioId
        bpm.date = date
        bpm.bpm = nowBPM
        bpm.ts = ts
        bpmModels.append(bpm)
    }
    
    
    func dataHandle(){
        
        // 接收到心跳数据
        tracker.dataHandle = { nowBPM, date in
            guard self.audioModel != nil else { return }
            
            let nowBPM = self.tracker.getNowBPM()
            let minBPM = self.tracker.getMinBPM()
            let maxBPM = self.tracker.getMaxBPM()
            let avgBPM = self.tracker.getAverageBPM()
            let bpms = self.tracker.getAllBPM()
            
            let progress = Double(nowBPM)/220.0
            self.recordView.progress.progress = progress
            self.recordView.avgBar.maxBPMLabel.text = "\(maxBPM)"
            self.recordView.avgBar.minBPMLabel.text = "\(minBPM)"
            self.recordView.avgBar.avgBPMLabel.text = "\(avgBPM)"
            self.recordView.avgBar.nowBPMLabel.text = "\(nowBPM)"
            self.recordView.updateChartData(bpms: bpms)
            
            self.newBPMEntity(nowBPM: nowBPM, date: date, ts: self.rec.currentTime)
        }
        
        // 录音进度
        self.rec.recordingHandle = { [weak self] seconds, decibel in
            self?.recordView.timeLabel.text = seconds
        }
        
        // 录音完成
        self.rec.recordedHandle = { [weak self] recordURL, duration, size in
            if let model = self?.audioModel, let bpmModels = self?.bpmModels {
                model.duration = duration
                model.size = size
                PersistManager.shared.insertAudio(audioEntity:  model)
                PersistManager.shared.saveBPMs(bpmModels, forAudio: model)
                self?.audioModel = nil
                self?.bpmModels.removeAll()
                
                if let url = SRTExporter.exportSRTFile(forAudio: model, withBPMs: bpmModels){
                    
                }
            }
        }
    }
}
