//
//  MessageCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

enum PositionInBlock {
    case top
    case center
    case bottom
    case single
}


open class MessageCell: UITableViewCell {
    
     open var styles = ChatKit.Styles
    
     open weak var delegate: MessageCellDelegate?
    
     var bubbleView: UIView = {
        let bubble = UIView()
        bubble.layer.cornerRadius = 20
        bubble.clipsToBounds = true
        return bubble
    }()
    
    
     var stackView: UIStackView = {
         let stackView = UIStackView()
         stackView.backgroundColor = .clear
         stackView.axis = .vertical
         stackView.distribution = .fill
         stackView.alignment = .leading
         stackView.isLayoutMarginsRelativeArrangement = true
         return stackView
     }()
    
     var messageStatusView: MessageStatusView = {
        let view = MessageStatusView()
        view.backgroundColor = .clear
        return view
    }()

    private var avatar: UIImageView = {
          let image = UIImageView()
          image.clipsToBounds = true
          image.layer.cornerRadius = 15
          image.layer.masksToBounds = true
          image.backgroundColor = .red
          image.contentMode = .scaleAspectFit
         return image
     }()
    
    private var displayname: UILabel = {
        let lab = PaddingLabel(withInsets: 0, 3, 10, 0)
        lab.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lab.text = "Faris Albalawi"
        return lab
     }()
    
     var leftConstrain: NSLayoutConstraint!
     var rightConstrain: NSLayoutConstraint!
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(stackView)
        stackView.addArrangedSubview(bubbleView)
        stackView.addArrangedSubview(messageStatusView)
        
        setupUIElements()
    
    }
    
     func isShowingAvatar() {
        self.addSubview(avatar)
        self.stackView.insertArrangedSubview(displayname, at: 0)
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 15)
        avatar.anchor(left: leftAnchor,bottom: bottomAnchor,paddingLeft: 5,paddingBottom: 5, width: 30,height: 30)
        
        stackView.anchor(top: topAnchor,bottom: bottomAnchor)
        
        leftConstrain = stackView.leftAnchor.constraint(equalTo: avatar.rightAnchor)
        rightConstrain = stackView.rightAnchor.constraint(equalTo: rightAnchor)
        displayname.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 0)
           
    }
    
    func isHidingAvater() {
        self.avatar.removeFromSuperview()
        self.displayname.removeFromSuperview()
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 15, bottom: 2, right: 15)
        stackView.anchor(top: topAnchor,bottom: bottomAnchor)
        leftConstrain = stackView.leftAnchor.constraint(equalTo: leftAnchor)
        rightConstrain = stackView.rightAnchor.constraint(equalTo: rightAnchor)
    }
    

    
   func setupUIElements() {}
    
    
    func bind(withMessage message: Messages) {
        tranformUI(message.isIncoming)
    }
    
    
    func tranformUI(_ isIncoming: Bool) {}
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     /// Update cell position In Block (IsIncoming)
    func updateLayoutForBubbleStyleIsIncoming(_ positionInBlock: PositionInBlock) {
         switch positionInBlock {
         case .top:
             avatar.isHidden = true
             displayname.isHidden = false
             
             messageStatusView.isHidden = true
             bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
         case .center:
             avatar.isHidden = true
             displayname.isHidden = true
             messageStatusView.isHidden = true
             bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
         case .bottom:
             avatar.isHidden = false
             displayname.isHidden = true
             messageStatusView.isHidden = false
             bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
         default:
             avatar.isHidden = false
             displayname.isHidden = false
             messageStatusView.isHidden = false
             bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            
         }
     }
    
    /// Update cell position In Block (outgoing)
    func updateLayoutForBubbleStyle(_ positionInBlock: PositionInBlock) {
        switch positionInBlock {
           case .top:
               messageStatusView.isHidden = true
               bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
           case .center:
               messageStatusView.isHidden = true
               bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
           case .bottom:
               messageStatusView.isHidden = false
               bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
           default:
               messageStatusView.isHidden = false
               bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
           }
       }

}
