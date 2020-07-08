//
//  MessagesMenus.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/22/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit

extension MessagesUI {
    
    // MARK: Menu
    /// if cell has text
    func TextContextMenu(text: String) -> UIMenu {
        var children = [UIMenuElement]()
        var menuChildren = [UIMenu]()
        let input = text
        
        /// if text has url && email
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            /// email
            if match.url?.scheme == "mailto" {
                  let email = input[range]

                let newEmail = UIAction(title: "New Mail Message", image: UIImage(systemName: "envelope")) { action in }
                
                let copyEmail = UIAction(title: "Copy Email", image: UIImage(systemName: "doc.on.doc")) { _ in
                     let pasteboard = UIPasteboard.general
                     pasteboard.string = "\(email)"
                 }
                
                let emilMenu = UIMenu(title: "\(email)", image: UIImage(systemName: "envelope"), options: .destructive, children: [copyEmail, newEmail])
              
                menuChildren.append(emilMenu)
              } else {
                    /// url
                  let url = input[range]
                  let openLink = UIAction(title: "Open Link", image: UIImage(systemName: "safari")) { action in }
                
                  let copylink = UIAction(title: "Copy Link", image: UIImage(systemName: "doc.on.doc")) { _ in
                      let pasteboard = UIPasteboard.general
                      pasteboard.string = "\(url)"
                  }
                
                 let urlMenu = UIMenu(title: "\(url)", image: UIImage(systemName: "link"), options: .destructive, children: [openLink, copylink])
                 menuChildren.append(urlMenu)
              }
        } // end
        
        
        /// if text has phone number
        let phonedetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        let phonematches = phonedetector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        for match in phonematches {
            
            guard let range = Range(match.range, in: input) else { continue }
            let number = input[range]
            
            let call = UIAction(title: "Call \(number)", image: UIImage(systemName: "phone.arrow.up.right")) { action in }
            
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = "\(number)"
            }
            
            
            let numberMenu = UIMenu(title: "\(number)", image: UIImage(systemName: "phone"), options: .destructive, children: [call, copy])
            menuChildren.append(numberMenu)
        }
        
    
  
        let copy = UIAction(title: "Copy All", image: UIImage(systemName: "doc.on.doc")) { _ in
            print("Copy")
            let pasteboard = UIPasteboard.general
            pasteboard.string = "\(text)"
        }
        
   
  
        for i in menuChildren {
              children.append(i)
          }
        children.append(copy)
        
        return UIMenu(title: "", children: children)
    }
    
    
    
    
    // ------------------------------------------ //
    
    /// if cell has image
    func ImageContextMenu() -> UIMenu {
        let saveToPhotos = UIAction(title: "Save to Photos", image: UIImage(systemName: "square.and.arrow.down.fill")) { _ in
            print("Save to Photos")
        }
        
        return UIMenu(title: "", children: [saveToPhotos])
    }
    
    
    // ------------------------------------------ //
    
  /// if cell is caption
  func CaptionContextMenu(text: String) -> UIMenu {
      var children = [UIMenuElement]()
      var menuChildren = [UIMenu]()
      let input = text
      
      /// if text has url && email
      let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
      let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
      for match in matches {
          guard let range = Range(match.range, in: input) else { continue }
          /// email
          if match.url?.scheme == "mailto" {
                let email = input[range]

              let newEmail = UIAction(title: "New Mail Message", image: UIImage(systemName: "envelope")) { action in }
              
              let copyEmail = UIAction(title: "Copy Email", image: UIImage(systemName: "doc.on.doc")) { _ in
                   let pasteboard = UIPasteboard.general
                   pasteboard.string = "\(email)"
               }
              
              let emilMenu = UIMenu(title: "\(email)", image: UIImage(systemName: "envelope"), options: .destructive, children: [copyEmail, newEmail])
            
              menuChildren.append(emilMenu)
            } else {
                  /// url
                let url = input[range]
                let openLink = UIAction(title: "Open Link", image: UIImage(systemName: "safari")) { action in }
              
                let copylink = UIAction(title: "Copy Link", image: UIImage(systemName: "doc.on.doc")) { _ in
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = "\(url)"
                }
              
               let urlMenu = UIMenu(title: "\(url)", image: UIImage(systemName: "link"), options: .destructive, children: [openLink, copylink])
               menuChildren.append(urlMenu)
            }
      } // end
      
      
      /// if text has phone number
      let phonedetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
      let phonematches = phonedetector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
      for match in phonematches {
          
          guard let range = Range(match.range, in: input) else { continue }
          let number = input[range]
          
          let call = UIAction(title: "Call \(number)", image: UIImage(systemName: "phone.arrow.up.right")) { action in }
          
          let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
              let pasteboard = UIPasteboard.general
              pasteboard.string = "\(number)"
          }
          
          
          let numberMenu = UIMenu(title: "\(number)", image: UIImage(systemName: "phone"), options: .destructive, children: [call, copy])
          menuChildren.append(numberMenu)
      }
      
  
    let saveToPhotos = UIAction(title: "Save to Photos", image: UIImage(systemName: "square.and.arrow.down.fill")) { _ in
         print("Save to Photos")
     }
    

      let copy = UIAction(title: "Copy All", image: UIImage(systemName: "doc.on.doc")) { _ in
          print("Copy")
          let pasteboard = UIPasteboard.general
          pasteboard.string = "\(text)"
      }
      
 

      for i in menuChildren {
            children.append(i)
        }
      children.append(copy)
      children.append(saveToPhotos)
      
      return UIMenu(title: "", children: children)
  }

}
