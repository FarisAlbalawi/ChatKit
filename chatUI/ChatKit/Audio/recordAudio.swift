//
//  recordAudio.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/1/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol recordDelegate {
    func AudioFile(_ url:URL)
}

class recordAudio: UIView, AVAudioRecorderDelegate {
    
    
    var delegate: recordDelegate?
    
    
    private let timeLab: UILabel = {
        let lab = UILabel()
        lab.text = "00:00"
        lab.textColor = .systemGray2
        lab.font = UIFont.systemFont(ofSize: 55, weight: .black)
        return lab
    }()
    
    private let recordButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Record", for: .normal)
        butt.titleLabel?.textColor = .white
        butt.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .black)
        butt.backgroundColor = .lightRed
        butt.layer.cornerRadius = 55/2
        butt.addTarget(self, action: #selector(didPressRecord), for: UIControl.Event.touchUpInside)
        butt.tag = 0
        return butt
    }()
    
    private let CancelButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Cancel", for: .normal)
        butt.titleLabel?.textColor = .white
        butt.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .black)
        butt.backgroundColor = .systemGray2
        butt.layer.cornerRadius = 55/2
        butt.addTarget(self, action: #selector(didPressCancel), for: UIControl.Event.touchUpInside)
        butt.tag = 0
        return butt
    }()
    
    private var stackView: UIStackView = {
         let stackView = UIStackView()
         stackView.backgroundColor = .clear
         stackView.axis = .horizontal
         stackView.distribution = .fill
         stackView.alignment = .fill
         stackView.spacing = 10
         stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
         stackView.isLayoutMarginsRelativeArrangement = true
         return stackView
     }()
    
    private var sendWidth = NSLayoutConstraint()
    private var cancelWidth = NSLayoutConstraint()
    private var selectedWidth = CGFloat()
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var meterTimer: Timer!
    
    private var state: AudioRecorderState = .Ready
    private var recorder: AudioRecorder = AudioRecorder(withFileName: "recording.m4a")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        
        recorder.delegate = self

        
    }
    
    func setupUIElements() {
        selectedWidth = (UIScreen.main.bounds.width  - 50 )
        self.layer.cornerRadius = 10
        self.addSubview(timeLab)
        self.addSubview(stackView)
        self.stackView.addArrangedSubview(CancelButton)
        self.stackView.addArrangedSubview(recordButton)
        
        self.timeLab.center(inView: self, yConstant: -40)
        self.stackView.center(inView: self, yConstant: 70)
        
        self.sendWidth = self.recordButton.widthAnchor.constraint(equalToConstant: selectedWidth)
        self.cancelWidth = self.CancelButton.widthAnchor.constraint(equalToConstant: 0)
        self.recordButton.anchor(height: 55)
        self.CancelButton.anchor(height: 55)
        NSLayoutConstraint.activate([cancelWidth,sendWidth])
   
        
    }
    
    /// Record
    @objc private func didPressRecord(_ sender: UIButton) {
        if sender.tag == 0 {
            self.recordButton.tag = 1
            self.recordButton.setTitle("Send", for: .normal)
            self.recordButton.backgroundColor = .mainBlue
            self.sendWidth.constant = selectedWidth / 2
            self.cancelWidth.constant = selectedWidth / 2
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
            recorder.doRecord()
        } else {
            recorder.doStopRecording()
            delegate?.AudioFile(recorder.fileUrl())
            self.recordButton.tag = 0
            self.recordButton.setTitle("Record", for: .normal)
            self.recordButton.backgroundColor = .lightRed
            self.sendWidth.constant = selectedWidth
            self.cancelWidth.constant = 0
            self.timeLab.text = "00:00"
     
            
        }
   
    }
    
    /// cancel
    @objc private func didPressCancel(_ sender: Any?) {
        self.recordButton.tag = 0
        self.recordButton.setTitle("Record", for: .normal)
        self.recordButton.backgroundColor = .lightRed
        self.sendWidth.constant = selectedWidth
        self.cancelWidth.constant = 0
        self.recorder.doStopRecording()
        self.timeLab.text = "00:00"
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
     }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension recordAudio: AudioRecorderDelegate {
    func audioRecorder(_ recorder: AudioRecorder, withStates state: AudioRecorderState) {
        switch state {
        case .error(let e): debugPrint(e)
        case .Failed(let s): debugPrint(s)
        case .Finish:
            print("Finish")
        case .Recording:
             print("Recording")
        case .Ready:
            print("Ready")
        }
        debugPrint(state)
    }

    func audioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {
        self.timeLab.text = formattedString
    }
}
