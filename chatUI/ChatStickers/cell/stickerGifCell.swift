//
//  stickerGifCell.swift
//  chatUI
//
//  Created by Faris Albalawi on 7/9/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class stickerGifCell: UICollectionViewCell {
    
    var stickerImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.stickerImage.contentMode = .scaleAspectFit
        stickerImage.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stickerImage)
        
        let constraints = [
            
            stickerImage.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            stickerImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            stickerImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            stickerImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            
            ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    
}
