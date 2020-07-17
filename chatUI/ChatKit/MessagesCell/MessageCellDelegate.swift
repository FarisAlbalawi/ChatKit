//
//  MessageCellDelegate.swift
//  chatUI
//
//  Created by Faris Albalawi on 7/16/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit
/// A protocol used by `MessageContentCell` subclasses to detect taps in the cell's subviews.
public protocol MessageCellDelegate: ContextLabelDelegate {
  

    func didTapAvatar(in cell: MessageCell)
    func didTapImage(in cell: MessageCell)
    func didTapPlayButton(in cell: MessageCell)
    func didStartAudio(in cell: MessageCell)
    func didPauseAudio(in cell: MessageCell)
    func didStopAudio(in cell: MessageCell)

}

public extension MessageCellDelegate {

    func didTapAvatar(in cell: MessageCell) {}
    func didTapImage(in cell: MessageCell) {}
    func didTapPlayButton(in cell: MessageCell) {}
    func didStartAudio(in cell: MessageCell) {}
    func didPauseAudio(in cell: MessageCell) {}
    func didStopAudio(in cell: MessageCell) {}


}

/// A protocol used to handle tap events on detected text.
public protocol MessageLabelDelegate: AnyObject {
    func contextLabel(_ sender: ContextLabel, textFontForLinkResult linkResult: LinkResult) -> UIFont
    
    func contextLabel(_ sender: ContextLabel, foregroundColorForLinkResult linkResult: LinkResult) -> UIColor
    
    func contextLabel(_ sender: ContextLabel, foregroundHighlightedColorForLinkResult linkResult: LinkResult) -> UIColor
    
    func contextLabel(_ sender: ContextLabel, underlineStyleForLinkResult linkResult: LinkResult) -> NSUnderlineStyle

    func contextLabel(_ sender: ContextLabel, modifiedAttributedString attributedString: NSAttributedString) -> NSAttributedString

    func contextLabel(_ sender: ContextLabel, didTouchWithTouchResult touchResult: TouchResult)
    
    func contextLabel(_ sender: ContextLabel, didCopy text: String?)

}

public extension MessageLabelDelegate {
    func contextLabel(_ sender: ContextLabel, textFontForLinkResult linkResult: LinkResult) -> UIFont {
        return UIFont.systemFont(ofSize: 16)
        
    }
    
    func contextLabel(_ sender: ContextLabel, foregroundColorForLinkResult linkResult: LinkResult) -> UIColor {
        return .clear
    }
    
    func contextLabel(_ sender: ContextLabel, foregroundHighlightedColorForLinkResult linkResult: LinkResult) -> UIColor {
        return .clear
    }
    
    func contextLabel(_ sender: ContextLabel, underlineStyleForLinkResult linkResult: LinkResult) -> NSUnderlineStyle {
        return .single
    }

    func contextLabel(_ sender: ContextLabel, modifiedAttributedString attributedString: NSAttributedString) -> NSAttributedString {
        return attributedString
    }

    func contextLabel(_ sender: ContextLabel, didTouchWithTouchResult touchResult: TouchResult) {}
    
    func contextLabel(_ sender: ContextLabel, didCopy text: String?) {}
}
