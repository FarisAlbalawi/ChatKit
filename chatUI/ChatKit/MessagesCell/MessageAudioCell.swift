//
//  MessageAudioCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit
import AVFoundation


open class MessageAudioCell: MessageCell, AVAudioPlayerDelegate {

  static var reuseIdentifier = "MessageAudioCell"
    

    let progressSlider: UISlider = {
        let slider = UISlider()
        slider.thumbTintColor = .white
        let newImage = slider.thumbImage(for: .normal)!.generateNewImage(scaledToSize: CGSize(width: 5, height: 5))
        slider.setThumbImage(newImage, for: .normal)
        slider.isContinuous = true
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
    open override func prepareForReuse() {
         super.prepareForReuse()
      
     }
    
    override func setupUIElements() {
        self.playBtn.addTarget(self, action: #selector(play_pause), for: UIControl.Event.touchUpInside)
        self.progressSlider.addTarget(self, action: #selector(sliderPlayer), for: .touchDragInside)
        self.bubbleView.addSubview(playBtn)
        self.bubbleView.addSubview(progressSlider)
        self.bubbleView.addSubview(time)
        self.bubbleView.addSubview(totalTime)
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        bubbleView.anchor(width:bounds.width - 40 )
        playBtn.anchor(top:bubbleView.topAnchor,left:bubbleView.leftAnchor,paddingTop:5,paddingLeft: 10,width: 30,height: 30)
        
        progressSlider.anchor(top:bubbleView.topAnchor,left: playBtn.rightAnchor,right: bubbleView.rightAnchor,paddingTop:15,paddingLeft:10,paddingRight: 10 )
        
        time.anchor(top:progressSlider.bottomAnchor,left: playBtn.rightAnchor,bottom:bubbleView.bottomAnchor,paddingTop: 10,paddingLeft: 10,paddingBottom: 5)
        totalTime.anchor(top:progressSlider.bottomAnchor,bottom:bubbleView.bottomAnchor,right:bubbleView.rightAnchor ,paddingTop: 10,paddingBottom:5, paddingRight: 10)
        
        
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
            progressSlider.thumbTintColor = .black()
            playBtn.tintColor = .black()
            progressSlider.tintColor = .black()
            time.textColor = .black()
            totalTime.textColor = .black()
            bubbleView.backgroundColor = .systemGray6
            leftConstrain.isActive = true
            rightConstrain.isActive = false
            stackView.alignment = .leading
            messageStatusView.setupConstraints(.left)
            messageStatusView.layoutIfNeeded()
        } else {
            progressSlider.thumbTintColor = .white
            playBtn.tintColor = .white
            progressSlider.tintColor = .white
            time.textColor = .white
            totalTime.textColor = .white
            bubbleView.backgroundColor = .mainBlue
            leftConstrain.isActive = false
            rightConstrain.isActive = true
            stackView.alignment = .trailing
            messageStatusView.setupConstraints(.right)
            messageStatusView.layoutIfNeeded()
        }
        
        
        let newImage = progressSlider.thumbImage(for: .normal)!.generateNewImage(scaledToSize: CGSize(width: 5, height: 5))
        progressSlider.setThumbImage(newImage, for: .normal)
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
            player.currentTime =  TimeInterval(progressSlider.value)
            player.play()
        }else{
            player.currentTime = TimeInterval(progressSlider.value)
        }
    }
    
    func updateTime() {
         guard let player = audioPlayer else {return}
         Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
         progressSlider.maximumValue = Float(player.duration)
         totalTime.text = stringFormatterTimeInterval(interval: player.duration) as String
     }
    
    @objc func update (_timer : Timer ) {
         guard let player = audioPlayer else {return}
        progressSlider.value = Float(player.currentTime)
        time.text =  stringFormatterTimeInterval(interval: TimeInterval(progressSlider.value)) as String
    }
    
    func stringFormatterTimeInterval(interval : TimeInterval) ->NSString {
        let ti = NSInteger(interval)
        let second = ti % 60
        let minutes = ( ti / 60) % 60
        return NSString(format: "%0.2d:%0.2d", minutes,second)
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
         guard let player = audioPlayer else {return}
        if flag == true {
           self.playBtn.setImage(UIImage(named: "play_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
           player.pause()
        }
    }
    
}

