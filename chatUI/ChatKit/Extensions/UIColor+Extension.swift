//
//  UIColor+Extension.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func white() -> UIColor {
        return UIColor.init { (trait) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
    }
    
    static func black() -> UIColor {
        return UIColor.init { (trait) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }
    }
    
    static func setColor(_ Dark: UIColor, Light: UIColor) -> UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ? Dark : Light
        }
    }
    
    static let darkBackground = UIColor(red: 0.1098, green: 0.1098, blue: 0.1176, alpha: 1.0)
    
    static let mainBlue = UIColor(red: 0.2627, green: 0.5882, blue: 0.9686, alpha: 1.0)
    static let lightRed = UIColor(red: 235/255, green: 84/255, blue: 103/255, alpha: 1.0)
    
 

}
