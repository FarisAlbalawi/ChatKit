//
//  MessageStatusView.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/22/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

enum positionStatus {
    case left
    case right
}

class MessageStatusView: UIView {
    
    
    lazy var dateLab: UILabel = {
          let lab = UILabel()
          lab.font = UIFont.systemFont(ofSize: 12)
          lab.textColor = .systemGray2
          lab.numberOfLines = 0
          return lab
      }()
    
     lazy var statusIcon: UIImageView = {
        let icons = UIImageView(image: UIImage(systemName: "checkmark.circle")?.withTintColor(UIColor.black, renderingMode: .alwaysTemplate))
         icons.tintColor = UIColor.systemGray2
         icons.contentMode = .scaleAspectFit
         return icons
         
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dateLab)
        addSubview(statusIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

     func setupConstraints(_ position:positionStatus) {
        switch position {
        case .left:
            statusIcon.isHidden = true
            dateLab.textAlignment = .left
            dateLab.anchor(top: topAnchor,left: leftAnchor,bottom: bottomAnchor,paddingTop: 5,paddingBottom: 5)
            
        case .right:
            statusIcon.isHidden = false
            statusIcon.anchor(right: rightAnchor,width: 12,height: 12)
            dateLab.textAlignment = .right
            dateLab.anchor(top: topAnchor,bottom: bottomAnchor,right: statusIcon.leftAnchor,paddingTop: 5,paddingBottom: 5,paddingRight: 2)
            statusIcon.centerY(inView: dateLab)
        }
        
    }

}
