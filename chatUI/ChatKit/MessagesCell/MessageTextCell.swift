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
    
   private lazy var messageLabel: ContextLabel = {
        let messageLabel = ContextLabel()
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .natural
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
        messageLabel.delegate = self
        bubbleView.addSubview(messageLabel)
        messageLabel.preferredMaxLayoutWidth = bounds.width - 40
        setupConstraints()
    }
    
    private func setupConstraints() {
        messageLabel.anchor(top: bubbleView.topAnchor,left: bubbleView.leftAnchor
               ,bottom: bubbleView.bottomAnchor,right: bubbleView.rightAnchor,
                paddingTop: 15,paddingLeft: 15,paddingBottom: 15,paddingRight: 15)
    }
    
    
    
    override func bind(withMessage message: Messages) {
        messageLabel.text = message.text
        let date = dateFormatTime(date: message.createdAt)
        messageStatusView.dateLab.text = date
        tranformUI(message.isIncoming)
    }
    
    // add constraints to subviews and set color
    override func tranformUI(_ isIncoming: Bool) {
        super.tranformUI(isIncoming)
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


extension MessageTextCell :ContextLabelDelegate {
    func contextLabel(_ sender: ContextLabel, textFontForLinkResult linkResult: LinkResult) -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    func contextLabel(_ sender: ContextLabel, foregroundColorForLinkResult linkResult: LinkResult) -> UIColor {
        return .lightGray
    }
    
    func contextLabel(_ sender: ContextLabel, foregroundHighlightedColorForLinkResult linkResult: LinkResult) -> UIColor {
        return .lightGray
    }
    
    func contextLabel(_ sender: ContextLabel, underlineStyleForLinkResult linkResult: LinkResult) -> NSUnderlineStyle {
        return .single
    }
    
    func contextLabel(_ sender: ContextLabel, modifiedAttributedString attributedString: NSAttributedString) -> NSAttributedString {
        return attributedString
    }
    
    func contextLabel(_ sender: ContextLabel, didTouchWithTouchResult touchResult: TouchResult) {
         guard let textLink = touchResult.linkResult else { return }
         switch touchResult.state {
           case .ended:
               switch textLink.detectionType {
               case .url:
                   print("url \(textLink.text)")
               case .email:
                   print("email \(textLink.text)")
               case .phoneNumber:
                   print("phoneNumber \(textLink.text)")
               default:
                   print("default")
               }
               
           default:
               break
           }
    }
    
    func contextLabel(_ sender: ContextLabel, didCopy text: String?) {
        
    }
    
    
}
