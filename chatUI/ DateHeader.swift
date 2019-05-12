//
//   DateHeader.swift
//  chatUI
//
//  Created by Faris Albalawi on 5/12/19.
//  Copyright © 2019 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit


class DateHeader: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.9294, alpha: 1.0)
        textColor = UIColor.black
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 10
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
    
}
