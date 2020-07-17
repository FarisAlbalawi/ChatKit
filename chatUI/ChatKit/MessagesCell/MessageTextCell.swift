//
//  MessageTextCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit


class MessageTextCell: MessageCell {
    
   static var reuseIdentifier = "MessageTextCell"
    

    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    
   private var messageLabel: ContextLabel = {
        let messageLabel = ContextLabel()
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.determineTextDirection()
        messageLabel.numberOfLines = 0
        messageLabel.lineSpacing = 2
        messageLabel.sizeToFit()
        return messageLabel
    }()

    
    override func prepareForReuse() {
         super.prepareForReuse()
         messageLabel.attributedText = nil
         messageLabel.text = nil
        
     }
    
    override func setupUIElements() {
        bubbleView.addSubview(messageLabel)
        messageLabel.preferredMaxLayoutWidth = bounds.width - 40
        setupConstraints()
    }
    
    private func setupConstraints() {
        messageLabel.anchor(top: bubbleView.topAnchor,left: bubbleView.leftAnchor
               ,bottom: bubbleView.bottomAnchor,right: bubbleView.rightAnchor,
                paddingTop: 10,paddingLeft: 10,paddingBottom: 10,paddingRight: 10)
    }
    
    
    
    override func bind(withMessage message: Messages) {
        tranformUI(message.isIncoming)
        messageLabel.text = message.text
        messageLabel.determineTextDirection()
        let date = dateFormatTime(date: message.createdAt)
        messageStatusView.dateLab.text = date
        
    }
    
    // add constraints to subviews and set color
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

