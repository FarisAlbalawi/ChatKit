//
//  MessageImageCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class MessageImageCell: MessageCell {
    
    static var reuseIdentifier = "MessageImageCell"

    private var attachImageView: UIImageView = {
         let image = UIImageView()
         image.clipsToBounds = true
         image.translatesAutoresizingMaskIntoConstraints = false
         image.contentMode = .scaleAspectFill
        return image
    }()
    
    override func prepareForReuse() {
         super.prepareForReuse()
         attachImageView.image = nil
     }
    
    override func setupUIElements() {
        backgroundColor = .clear
        bubbleView.addSubview(attachImageView)
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        let imageWidth = ["imageWidth": bounds.width - 40]
        let viewsDictionary = ["image": attachImageView]
        bubbleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image(<=imageWidth@999)]|", metrics: imageWidth, views: viewsDictionary))
        bubbleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image(<=imageWidth@999)]|", metrics: imageWidth, views: viewsDictionary))
        

    }
    
    override func bind(withMessage message: Messages) {
         let date = dateFormatTime(date: message.createdAt)
         self.attachImageView.image = message.image!
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
