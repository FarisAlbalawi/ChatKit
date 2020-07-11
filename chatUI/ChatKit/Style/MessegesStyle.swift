//
//  MessegesStyle.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/13/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

public protocol MessegesStyle {
    
    /// The background color of the chat view
    var backgroundColor: UIColor { get }
    
    /// The placeholder that is displayed in the input view
    var inputPlaceholder: String { get }
    
    /// The color of text used by the placeholder in input view
    var inputPlaceholderTextColor: UIColor { get }
    
    /// The color of the textview in the input view
    var inputTextViewBackgroundColor : UIColor { get }
    
    /// The text color of outgoing messages
    var outgoingTextColor: UIColor { get }
    
     /// The text Bubble of outgoing messages
    var outgoingBubbleColor: UIColor { get }
    
    /// The text color of incoming messages
    var incomingTextColor: UIColor { get }
    
    /// The text Bubble of incoming messages
    var incomingBubbleColor: UIColor { get }

    /// The color of the icons in the input view
    var inputIconsColor : UIColor { get }
    
    /// send icon image in input view
    var sendIcon : UIImage { get }
    
    /// media icon image in input view
    var mediaIcon : UIImage { get }
    
    /// media icon image in input view
    var audioIcon : UIImage { get }
    
    /// Stickers icon image in input view
    var stickersIcon : UIImage { get }
    
    /// more icon image in input view
    var moreIcon : UIImage { get }
    
    /// quick Emoji Icon image in input view
    var quickEmojiIcon : UIImage { get }
    
    /// cancel icon image in input view after showing the quick Emoji view
    var cancelIcon : UIImage { get }
    
    
    var isSupportImages : Bool { get }
    
    
    var isSupportVidos : Bool { get }
    
    
    var isSupportMap : Bool { get }
    
    var isSupportDocuments: Bool { get }
    
    
    var isSupportAudio : Bool { get }
    
    
    var isSupportQuickEmoji : Bool { get }
    
    
    var isSupportStickers : Bool { get }
    
    var showingAvataer : Bool { get }
    

    
}


public struct chatUIStyle: MessegesStyle {
    
    
    public var showingAvataer: Bool = true
    
    public var isSupportImages: Bool = true
    
    public var isSupportVidos: Bool = true
    
    public var isSupportMap: Bool = true
    
    public var isSupportDocuments: Bool = true
    
    public var isSupportAudio: Bool = true
    
    public var isSupportQuickEmoji: Bool = true
    
    public var isSupportStickers: Bool = true
    
    public var cancelIcon: UIImage = UIImage(named: "cancel_icon")!
    
    public var sendIcon: UIImage = UIImage(named: "send_icon")!
    
    public var mediaIcon: UIImage = UIImage(named: "photo_icon")!
    
    public var audioIcon: UIImage = UIImage(named: "audio_icon")!
    
    public var stickersIcon: UIImage = UIImage(named: "emoji_icon")!
    
    public var moreIcon: UIImage = UIImage(named: "more_icon")!
    
    public var quickEmojiIcon: UIImage = UIImage(named: "like_icon")!
    
    public var inputIconsColor: UIColor = UIColor(red: 0.2627, green: 0.5882, blue: 0.9686, alpha: 1.0)

    public var backgroundColor: UIColor = .setColor(.systemBackground, Light: .systemBackground)
    
    public var inputPlaceholder: String = "Message"
    
    public var inputPlaceholderTextColor: UIColor = .setColor(.systemGray2, Light: .systemGray2)
    
    public var inputTextViewBackgroundColor: UIColor = .setColor(.systemGray6, Light: .systemGray6)
    
    public var outgoingTextColor: UIColor = .setColor(.white, Light: .white)
    
    public var outgoingBubbleColor: UIColor = .setColor(UIColor(red: 0.2627, green: 0.5882, blue: 0.9686, alpha: 1.0), Light: UIColor(red: 0.2627, green: 0.5882, blue: 0.9686, alpha: 1.0))
    
    public var incomingTextColor: UIColor = .setColor(.white, Light: .black)
    
    public var incomingBubbleColor: UIColor = .setColor(.systemGray6, Light: .systemGray6)
    
    
}
