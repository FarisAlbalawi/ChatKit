//
//  AudioRecorder.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/3/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit
import AVFoundation

enum AudioRecorderState {
    case Finish
    case Failed(String)
    case Recording
    case Ready
    case error(Error)
}

protocol AudioRecorderDelegate {
 
    func audioRecorder(_ recorder: AudioRecorder, withStates state: AudioRecorderState)
    func audioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String)
}

class AudioRecorder: NSObject {

    private var isAudioRecordingGranted: Bool = false
    private var filename: String = ""
    
    private var recorderState: AudioRecorderState = .Ready {
        willSet{
            delegate?.audioRecorder(self, withStates: newValue)
        }
    }
    
    private var audioRecorder: AVAudioRecorder! = nil
    private var audioPlayer: AVAudioPlayer! = nil
    private var meterTimer: Timer! = nil
    private var currentTimeInterval: TimeInterval = 0.0
    
    var delegate: AudioRecorderDelegate?
    
    init(withFileName filename: String) {
        super.init()
        
        self.recorderState = .Ready
        self.filename = filename
        self.check_record_permission()
    }
    
    private func check_record_permission() {
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        @unknown default:
           print("Error")
        }
    }
    
    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func fileUrl() -> URL {
        let filename = "\(self.filename)"
        let filePath = documentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    

    
    private func setupRecorder() {
        
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default,options: [.allowAirPlay,.allowBluetooth,.allowBluetoothA2DP,.defaultToSpeaker,.mixWithOthers])
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: fileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                self.recorderState = .Ready
            }
            catch let error {
                recorderState = .error(error)
            }
            
        }
        else {
            recorderState = .Failed("Don't have access to use your microphone.")
        }
    }
    
    @objc private func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            currentTimeInterval = currentTimeInterval + 0.01
            let min = Int(currentTimeInterval / 60)
            let sec = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            delegate?.audioRecorder(self, currentTime: currentTimeInterval, formattedString: totalTimeString)
            audioRecorder.updateMeters()
        }
    }
    
    private func finishAudioRecording(success: Bool) {
        if success {
            audioRecorder?.stop()
            meterTimer?.invalidate()
            recorderState = .Finish
        }
        else {
            recorderState = .Failed("Recording failed.")
        }
    }
    
    private func preparePlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            recorderState = .Ready
        }
        catch {
            recorderState = .error(error)
            debugPrint(error)
        }
    }
    
    func doRecord() {
        
        if audioRecorder == nil {
            setupRecorder()
        }
        
        if audioRecorder.isRecording {
            doStopRecording()
        }
        else {
            audioRecorder.record()
            currentTimeInterval = 0.0
            meterTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recorderState = .Recording
        }
    }
    
    func doStopRecording() {
        
        guard audioRecorder != nil else {
            return
        }
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            finishAudioRecording(success: true)
        } catch {
            recorderState = .error(error)
        }
    }
    
}

extension AudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    }
}
