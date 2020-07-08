//
//  EmojiCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/28/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class EmojiCell: UICollectionViewCell {
    var emojiLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.emojiLabel.sizeToFit()
        self.emojiLabel.font = emojiLabel.font.withSize(50)
        self.emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.emojiLabel)
        
        let constraints = [
            
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            emojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            
            ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
}
