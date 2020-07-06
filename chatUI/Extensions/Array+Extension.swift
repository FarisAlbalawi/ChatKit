//
//  Array+Extension.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/18/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation

extension Array {
    
    func item(before index: Int) -> Element? {
        if index < 1 {
            return nil
        }
        
        if index > count {
            return nil
        }
        
        return self[index - 1]
    }
    
    func item(after index: Int) -> Element? {
        if index < -1 {
            return nil
        }
        
        if index <= count - 2 {
            return self[index + 1]
        }
        
        return nil
    }
}
