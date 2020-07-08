//
//  MessageEmojiCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class MessageEmojiCell: MessageCell {
    
    static var reuseIdentifier = "MessageEmojiCell"

    private var EmojiImageView: UIImageView = {
         let image = UIImageView()
         image.clipsToBounds = true
         image.translatesAutoresizingMaskIntoConstraints = false
         image.contentMode = .scaleAspectFit
        return image
    }()
    
    override func prepareForReuse() {
         super.prepareForReuse()
         EmojiImageView.image = nil
     }
    
    override func setupUIElements() {
        backgroundColor = .clear
        bubbleView.backgroundColor = .clear
        bubbleView.addSubview(EmojiImageView)
        setupConstraints()
        
    }
    
    private func setupConstraints() {
         EmojiImageView.anchor(top: bubbleView.topAnchor,left: bubbleView.leftAnchor,bottom: bubbleView.bottomAnchor,
                                right: bubbleView.rightAnchor,paddingTop: 10,paddingBottom: 10)
        let width =  self.EmojiImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        let height = self.EmojiImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 100)
         width.priority = UILayoutPriority(999)
         height.priority = UILayoutPriority(999)
         NSLayoutConstraint.activate([width,height])
        

    }
    
    override func bind(withMessage message: Messages) {
         let date = dateFormatTime(date: message.createdAt)
         self.EmojiImageView.image = UIImage(named: message.stickerName!)
         self.messageStatusView.dateLab.text = date
      
        
        tranformUI(message.isIncoming)
    }
    
    override func tranformUI(_ isIncoming: Bool) {
        super.tranformUI(isIncoming)
        if isIncoming {
            leftConstrain.isActive = true
            rightConstrain.isActive = false
            stackView.alignment = .leading
            messageStatusView.setupConstraints(.left)
            messageStatusView.layoutIfNeeded()
        } else {
            leftConstrain.isActive = false
            rightConstrain.isActive = true
            stackView.alignment = .trailing
            messageStatusView.setupConstraints(.right)
            messageStatusView.layoutIfNeeded()
            
            
        }
    }

    
    

    
    
}
