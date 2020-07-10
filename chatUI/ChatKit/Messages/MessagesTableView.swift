//
//  MTableView.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/9/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit



extension MessagesUI: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections() ?? 0
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let message = dataSource?.headerTitle(for: section) else {
                   fatalError("Message not defined for \(section)")
            }
        
        if let firstMessageInSection = message.first {
            let date = Date()
            let dateString = MessagesViewModel.shared.chatTime(firstMessageInSection.createdAt, currentDate: date)
            let label = DateHeader()
            label.text = dateString
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.center(inView: containerView)
            
            
            return containerView
            
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return dataSource?.numberOfMessages(in: section) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chatMessage = dataSource?.message(for: indexPath) else {
                 fatalError("Message not defined for \(indexPath)")
             }
        let cellIdentifer = chatMessage.cellIdentifer()
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath) as! MessageCell
        let positionInBlock = MessagesViewModel.shared.getPositionInBlockForMessageAtIndex(indexPath.section, indexPath.row)

        // Update UI for cell
        if chatMessage.user.userId != currentUser.userId  {
            if style.showingAvataer == true {
                cell.isShowingAvatar()
                cell.layoutIfNeeded()
            } else {
                cell.isHidingAvater()
                cell.layoutIfNeeded()
            }
            cell.updateLayoutForBubbleStyleIsIncoming(positionInBlock)
            cell.layoutIfNeeded()
        } else {
            cell.isHidingAvater()
            cell.updateLayoutForBubbleStyle(positionInBlock)
            cell.layoutIfNeeded()
        }
        
        switch positionInBlock {
        case .bottom, .single:
            /// the last row (date show always)
            cell.messageStatusView.isHidden = false
             cell.layoutIfNeeded()
        default:
            cell.messageStatusView.isHidden = true
             cell.layoutIfNeeded()
        }
        

        cell.styles = self.style as! chatUIStyle
        cell.bind(withMessage:  chatMessage)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
       
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func updateCell(path: IndexPath){
        tableView.beginUpdates()
        tableView.reloadRows(at: [path], with: .none) //try other animations
        tableView.endUpdates()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MessageCell
        guard let Message = dataSource?.message(for: indexPath) else {
                 fatalError("Message not defined for \(indexPath)")
             }

        let chatMessage = Message
        let positionInBlock = MessagesViewModel.shared.getPositionInBlockForMessageAtIndex(indexPath.section, indexPath.row)

        // Update UI for cell
        if chatMessage.user.userId != currentUser.userId {
            cell.updateLayoutForBubbleStyleIsIncoming(positionInBlock)
            cell.layoutIfNeeded()
        } else {
            cell.updateLayoutForBubbleStyle(positionInBlock)
            cell.layoutIfNeeded()
        }
        
        switch positionInBlock {
        case .bottom, .single:
            /// the last row (date show always)
            cell.messageStatusView.isHidden = false
            cell.layoutIfNeeded()
        default:
            cell.messageStatusView.isHidden = true
            cell.layoutIfNeeded()
        }
        
        
    }
    
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MessageCell
        guard let Message = dataSource?.message(for: indexPath) else {
                 fatalError("Message not defined for \(indexPath)")
             }

        let chatMessage = Message
        let positionInBlock = MessagesViewModel.shared.getPositionInBlockForMessageAtIndex(indexPath.section, indexPath.row)

        // Update UI for cell
        if chatMessage.user.userId != currentUser.userId {
            cell.updateLayoutForBubbleStyleIsIncoming(positionInBlock)
            cell.layoutIfNeeded()
        } else {
            cell.updateLayoutForBubbleStyle(positionInBlock)
            cell.layoutIfNeeded()
        }
        
        switch positionInBlock {
        case .bottom, .single:
            /// the last row (date show always)
            cell.messageStatusView.isHidden = false
            cell.layoutIfNeeded()
        default:
            cell.messageStatusView.isHidden = true
            cell.layoutIfNeeded()
        }
     
    }
    
    
}

extension MessagesUI: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the cell for the index of the model
        guard let cell = tableView.cellForRow(at: .init(row: indexPath.row, section: indexPath.section)) as? MessageCell else { return }
        let positionInBlock = MessagesViewModel.shared.getPositionInBlockForMessageAtIndex(indexPath.section, indexPath.row)
        switch positionInBlock {
        case .bottom, .single:
            /// the last row (date show always)
            cell.messageStatusView.isHidden = false
        default:
            if cell.messageStatusView.isHidden {
                 cell.messageStatusView.isHidden = false
                 let loc = tableView.contentOffset
                 UIView.performWithoutAnimation {
                     tableView.layoutIfNeeded()
                     tableView.beginUpdates()
                     tableView.endUpdates()
                     tableView.layer.removeAllAnimations()
                 }
                 tableView.setContentOffset(loc, animated: true)
            } else {
                 cell.messageStatusView.isHidden = true
                 let loc = tableView.contentOffset
                 UIView.performWithoutAnimation {
                     tableView.layoutIfNeeded()
                     tableView.beginUpdates()
                     tableView.endUpdates()

                     tableView.layer.removeAllAnimations()
                 }
                 tableView.setContentOffset(loc, animated: true)
            }
        }
        
        
    }
    

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
       // Get the cell for the index of the model
       guard let cell = tableView.cellForRow(at: .init(row: indexPath.row, section: indexPath.section)) as? MessageCell else { return }
       let positionInBlock = MessagesViewModel.shared.getPositionInBlockForMessageAtIndex(indexPath.section, indexPath.row)
       switch positionInBlock {
       case .bottom, .single:
            /// the last row (date show always)
           cell.messageStatusView.isHidden = false
       default:
            cell.messageStatusView.isHidden = true
            let loc = tableView.contentOffset
            UIView.performWithoutAnimation {
                tableView.layoutIfNeeded()
                tableView.beginUpdates()
                tableView.endUpdates()

                tableView.layer.removeAllAnimations()
            }
            tableView.setContentOffset(loc, animated: true)
         
       }
        
    }
    
 
    
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource?.message(for: indexPath) else {
                 fatalError("Message not defined for \(indexPath)")
            }
        
        let identifier = ["row": indexPath.row, "section": indexPath.section]
        switch item.type {
        case .text:
             return UIContextMenuConfiguration(identifier: identifier as NSCopying, previewProvider: nil) { _ -> UIMenu? in
                return self.TextContextMenu(text: item.text!)
            }
        case .file:
             return UIContextMenuConfiguration(identifier: identifier as NSCopying, previewProvider: nil) { _ -> UIMenu? in
                return self.ImageContextMenu()
            }
        case .sticker:
            print("sticker")
        case .map:
            print("map")
        case .audio:
            print("audio")
        case .caption:
            return UIContextMenuConfiguration(identifier: identifier as NSCopying, previewProvider: nil) { _ -> UIMenu? in
                return self.CaptionContextMenu(text: item.text!)
            }
        case .gif:
            print("gif")
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

         // Ensure we can get the expected identifier
         guard let identifier = configuration.identifier as? [String : Int] else { return nil }

         print(configuration.identifier)
         // Get the current index of the identifier
         let row = identifier["row"]!
         let section = identifier["section"]!

         // Get the cell for the index of the model
         guard let cell = tableView.cellForRow(at: .init(row: row, section: section)) as? MessageCell else { return nil }

         // Since our preview has its own shape (a circle) we need to set the preview parameters
         // backgroundColor to clear, or we'll see a white rect behind it.
         let parameters = UIPreviewParameters()
         parameters.backgroundColor = .clear

         // Return a targeted preview using our cell previewView and parameters
         return UITargetedPreview(view: cell, parameters: parameters)
     }
    

}
