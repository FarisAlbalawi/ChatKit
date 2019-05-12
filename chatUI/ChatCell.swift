//
//  ChatCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 5/12/19.
//  Copyright © 2019 Faris Albalawi. All rights reserved.
//

import UIKit


class ChatCell: UITableViewCell {
    
    let messageLabel = UILabel()
    let dateLable = UILabel()
    let bubbleView = UIView()
    
    var leadingConstrain: NSLayoutConstraint!
    var trailingConstrain: NSLayoutConstraint!
    
    
    var chatMessage: ChatMessage! {
        didSet {
           
             messageLabel.text = chatMessage.text
            
            if chatMessage.isIncoming {
                bubbleView.backgroundColor = UIColor.white
                messageLabel.textColor = UIColor.black
                leadingConstrain.isActive = true
                trailingConstrain.isActive = false
                
            } else {
                bubbleView.backgroundColor = UIColor(red: 0.9843, green: 0.3451, blue: 0.4196, alpha: 1.0)
                messageLabel.textColor = UIColor.white
                leadingConstrain.isActive = false
                trailingConstrain.isActive = true
            }
            
        }
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        bubbleView.layer.cornerRadius = 4
        
        //  self.bubbleBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        self.messageLabel.clipsToBounds = true
        messageLabel.preferredMaxLayoutWidth = bounds.width - 40
        
        addSubview(bubbleView)
        addSubview(messageLabel)
        
        //  set up some constraints for our label
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
            //   messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
            ]
        NSLayoutConstraint.activate(constraints)
        
        leadingConstrain = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25)
        leadingConstrain.isActive = false
        
        trailingConstrain = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25)
        trailingConstrain.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
