//
//  ChatKit.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/14/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation


public final class ChatKit {
    
    /// The bundle that contains nibs and assets.
    internal static var bundle: Bundle? {
        let sourceBundle = Bundle(for: ChatKit.self)
        
        if let url = sourceBundle.url(forResource: "ChatKit", withExtension: "bundle"), let bundle = Bundle(url: url) {
            return bundle
        }
        
        return sourceBundle
    }
    
    private init() { }
    
     public static let Styles = chatUIStyle()
    
    
    
}

