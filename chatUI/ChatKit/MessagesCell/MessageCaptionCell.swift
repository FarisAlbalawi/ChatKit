//
//  MessageCaptionCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit

class MessageCaptionCell: MessageCell {
    
    static var reuseIdentifier = "MessageCaptionCell"

    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    private var messageLabel: ContextLabel = {
           let messageLabel = ContextLabel()
           messageLabel.font = UIFont.systemFont(ofSize: 16)
           messageLabel.numberOfLines = 0
           messageLabel.lineSpacing = 2
           messageLabel.sizeToFit()
           return messageLabel
       }()
    

  
    
    private var attachImageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    
    

    override func prepareForReuse() {
         super.prepareForReuse()
         attachImageView.image = nil
         messageLabel.attributedText = nil
         messageLabel.text = nil
 
     }
    
    override func setupUIElements() {
        backgroundColor = .clear
        messageLabel.preferredMaxLayoutWidth = bounds.width - 40
        bubbleView.addSubview(attachImageView)
        bubbleView.addSubview(messageLabel)
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        attachImageView.anchor(top: bubbleView.topAnchor,left: bubbleView.leftAnchor,
                               right: bubbleView.rightAnchor,paddingTop: 0,paddingLeft: 0,paddingRight: 0)
       let width =  self.attachImageView.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width - 40)
       let height = self.attachImageView.heightAnchor.constraint(lessThanOrEqualToConstant: bounds.width - 40)
        width.priority = UILayoutPriority(999)
        height.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([width,height])
        
        messageLabel.anchor(top: attachImageView.bottomAnchor,left: bubbleView.leftAnchor
                   ,bottom: bubbleView.bottomAnchor,right: bubbleView.rightAnchor,
                    paddingTop: 10,paddingLeft: 10,paddingBottom: 10,paddingRight: 10)
    }
    
    override func bind(withMessage message: Messages) {
         tranformUI(message.isIncoming)
         attachImageView.image =  message.image!
         messageLabel.text = message.text
         messageLabel.determineTextDirection()
         let date = dateFormatTime(date: message.createdAt)
         messageStatusView.dateLab.text = date
         
    }
    
    override func tranformUI(_ isIncoming: Bool) {
        super.tranformUI(isIncoming)
        messageLabel.isIncoming = isIncoming
        if isIncoming {
    
            messageLabel.textColor = styles.incomingTextColor
            bubbleView.backgroundColor = styles.incomingBubbleColor
            leftConstrain.isActive = true
            rightConstrain.isActive = false
            stackView.alignment = .leading
            messageStatusView.setupConstraints(.left)
            messageStatusView.layoutIfNeeded()
        } else {
            messageLabel.textColor = styles.outgoingTextColor
            bubbleView.backgroundColor = styles.outgoingBubbleColor
            leftConstrain.isActive = false
            rightConstrain.isActive = true
            stackView.alignment = .trailing
            messageStatusView.setupConstraints(.right)
            messageStatusView.layoutIfNeeded()
            
        }
    }
    
}

