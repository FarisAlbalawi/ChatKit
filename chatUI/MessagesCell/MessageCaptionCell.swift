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

    private lazy var captionLabel: ContextLabel = {
         let captionLabel = ContextLabel(frame: .zero, didTouch: { (touchResult) in
             self.contextLabel(didTouchWithTouchResult: touchResult)
         })

         // Custoim Underline Style
         captionLabel.underlineStyle = { (linkResult) in
             switch linkResult.detectionType {
             case .url, .email, .phoneNumber:
                 return .single
             default:
                 return []
             }
         }

         captionLabel.lineSpacing = 2
         captionLabel.font = UIFont.systemFont(ofSize: 15)
         captionLabel.textAlignment = .natural
         captionLabel.numberOfLines = 0
         captionLabel.sizeToFit()
         return captionLabel
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
         captionLabel.underlineStyle = { (linkResult) in
            switch linkResult.detectionType {
                case .url, .email, .phoneNumber:
                 return .single
                default:
                 return []
             }
         }
         captionLabel.text = nil
     }
    
    override func setupUIElements() {
        backgroundColor = .clear
        captionLabel.preferredMaxLayoutWidth = bounds.width - 40
        bubbleView.addSubview(attachImageView)
        bubbleView.addSubview(captionLabel)
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
        
        captionLabel.anchor(top: attachImageView.bottomAnchor,left: bubbleView.leftAnchor
                   ,bottom: bubbleView.bottomAnchor,right: bubbleView.rightAnchor,
                    paddingTop: 10,paddingLeft: 10,paddingBottom: 15,paddingRight: 10)
    }
    
    override func bind(withMessage message: Messages) {
         attachImageView.image =  message.image!
         captionLabel.text = message.text
         let date = dateFormatTime(date: message.createdAt)
         messageStatusView.dateLab.text = date
         tranformUI(message.isIncoming)
    }
    
    override func tranformUI(_ isIncoming: Bool) {
        super.tranformUI(isIncoming)
        if isIncoming {
    
            captionLabel.textColor = styles.incomingTextColor
            captionLabel.foregroundHighlightedColor = { (linkResult) in return self.styles.incomingTextColor }
            captionLabel.foregroundColor = { (linkResult) in return self.styles.incomingTextColor }
            
            bubbleView.backgroundColor = styles.incomingBubbleColor
            leftConstrain.isActive = true
            rightConstrain.isActive = false
            stackView.alignment = .leading
            messageStatusView.setupConstraints(.left)
            messageStatusView.layoutIfNeeded()
        } else {
            captionLabel.textColor = styles.outgoingTextColor
            captionLabel.foregroundHighlightedColor = { (linkResult) in return self.styles.outgoingTextColor }
            captionLabel.foregroundColor = { (linkResult) in return self.styles.outgoingTextColor }
        
            bubbleView.backgroundColor = styles.outgoingBubbleColor
            leftConstrain.isActive = false
            rightConstrain.isActive = true
            stackView.alignment = .trailing
            messageStatusView.setupConstraints(.right)
            messageStatusView.layoutIfNeeded()
            
        }
    }

    
    private func contextLabel(didTouchWithTouchResult touchResult: TouchResult) {
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
    
    
}

