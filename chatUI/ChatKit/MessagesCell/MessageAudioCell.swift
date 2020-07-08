//
//  MessageAudioCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit
import AVFoundation


class MessageAudioCell: MessageCell, AVAudioPlayerDelegate {

  static var reuseIdentifier = "MessageAudioCell"
    
   private let slider : UISlider = {
        let slider = UISlider()
        slider.maximumValue = 1000
        slider.minimumValue = 0
        return slider
    }()
    
    private let playBtn : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tag = 0
        return button
    }()
    
   private var time : UILabel = {
       let label = UILabel()
        label.text = "0:00"
        label.font = UIFont.systemFont(ofSize : 12)
        label.textColor = .blue
        return label
    }()
    
    
    private var totalTime : UILabel = {
          let label = UILabel()
          label.text = "0:00"
          label.font = UIFont.systemFont(ofSize : 12)
          label.textColor = .blue
          return label
      }()
    
    
    private var audioPlayer: AVAudioPlayer?

    private var url: URL?
    override func prepareForReuse() {
         super.prepareForReuse()
      
     }
    
    override func setupUIElements() {
        self.playBtn.addTarget(self, action: #selector(play_pause), for: UIControl.Event.touchUpInside)
        self.slider.addTarget(self, action: #selector(sliderPlayer), for: .touchDragInside)
        self.bubbleView.addSubview(playBtn)
        self.bubbleView.addSubview(slider)
        self.bubbleView.addSubview(time)
        self.bubbleView.addSubview(totalTime)
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        bubbleView.anchor(width:bounds.width - 40 )
        playBtn.anchor(top:bubbleView.topAnchor,left:bubbleView.leftAnchor,paddingTop:10,paddingLeft: 10,width: 30,height: 30)
        slider.anchor(top:bubbleView.topAnchor,left: playBtn.rightAnchor,right: bubbleView.rightAnchor,paddingTop:10,paddingLeft:10,paddingRight: 10 )
        time.anchor(top:slider.bottomAnchor,left: playBtn.rightAnchor,bottom:bubbleView.bottomAnchor,paddingTop: 5,paddingLeft: 10,paddingBottom: 10)
        totalTime.anchor(top:slider.bottomAnchor,bottom:bubbleView.bottomAnchor,right:bubbleView.rightAnchor ,paddingTop: 5,paddingBottom:10, paddingRight: 10)
        
        
    }
    
    override func bind(withMessage message: Messages) {
         let date = dateFormatTime(date: message.createdAt)
         self.messageStatusView.dateLab.text = date
         self.url = message.audio
         do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: self.url!)

            guard let player = audioPlayer else {return}
            player.prepareToPlay()
            player.delegate = self
            self.updateTime()
        } catch let error {
            print("\(error)")
        }
      
    
        
        tranformUI(message.isIncoming)
    }
    
    override func tranformUI(_ isIncoming: Bool) {
        super.tranformUI(isIncoming)
        if isIncoming {
            playBtn.tintColor = .black()
            slider.tintColor = .black()
            time.textColor = .black()
            totalTime.textColor = .black()
            bubbleView.backgroundColor = .systemGray6
            leftConstrain.isActive = true
            rightConstrain.isActive = false
            stackView.alignment = .leading
            messageStatusView.setupConstraints(.left)
            messageStatusView.layoutIfNeeded()
        } else {
            playBtn.tintColor = .white
            slider.tintColor = .white
            time.textColor = .white
            totalTime.textColor = .white
            bubbleView.backgroundColor = .mainBlue
            leftConstrain.isActive = false
            rightConstrain.isActive = true
            stackView.alignment = .trailing
            messageStatusView.setupConstraints(.right)
            messageStatusView.layoutIfNeeded()
        }
    }
    
    
    @objc func play_pause() {
        guard let player = audioPlayer else {return}
        if player.isPlaying {
            playBtn.setImage(UIImage(named: "play_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
            player.pause()
            updateTime()
        } else {
            playBtn.setImage(UIImage(named: "pause_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
            player.play()
            updateTime()

        }
        

   
    }
    
    
    @objc func sliderPlayer() {
        guard let player = audioPlayer else {return}
        if player.isPlaying {
            player.stop()
            player.currentTime =  TimeInterval(slider.value)
            player.play()
        }else{
            player.currentTime = TimeInterval(slider.value)
        }
    }
    
    func updateTime() {
         guard let player = audioPlayer else {return}
         Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
         slider.maximumValue = Float(player.duration)
         totalTime.text = stringFormatterTimeInterval(interval: player.duration) as String
     }
    
    @objc func update (_timer : Timer ) {
         guard let player = audioPlayer else {return}
        slider.value = Float(player.currentTime)
        time.text =  stringFormatterTimeInterval(interval: TimeInterval(slider.value)) as String
    }
    
    func stringFormatterTimeInterval(interval : TimeInterval) ->NSString {
        let ti = NSInteger(interval)
        let second = ti % 60
        let minutes = ( ti / 60) % 60
        return NSString(format: "%0.2d:%0.2d", minutes,second)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
         guard let player = audioPlayer else {return}
        if flag == true {
           self.playBtn.setImage(UIImage(named: "play_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
           player.pause()
        }
    }
    
}

