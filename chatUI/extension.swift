//
//  extension.swift
//  chatUI
//
//  Created by Faris Albalawi on 5/12/19.
//  Copyright © 2019 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit





extension chatView: UITextViewDelegate {
    
    // func loading when keyboard is shown
    @objc func keyboardWillShow(_ notification : Notification) {
        // move UI up
        // defnine keyboard frame size
        keyboard = ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        self.tableView.scrollToBottomRow()
        
        
    }
    
    
    
    
    //Settings
    func keyboardSettings(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:
            UIApplication.keyboardWillChangeFrameNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let swipeDown = UISwipeGestureRecognizer(target: self.view , action : #selector(UIView.endEditing(_:)))
        swipeDown.direction = .down
        
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func navigationBarsSettings() {
        bottomView.layer.cornerRadius = 13
        sendButton.layer.cornerRadius = 13
        self.bottomView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.bottomView.layer.shadowOpacity = 1.0
        self.bottomView.layer.shadowRadius = 5.0
        self.bottomView.layer.masksToBounds = false
    }
    
    
    func textViewSettings (){
        self.messageTextView.layer.cornerRadius = CGFloat(13)
        messageY = messageTextView.frame.origin.y
        messageTextView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    
    func tableViewSettings(){
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 53
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }    // end Settings
    
    
    
    
    //Keyboard Configure
    // while writing something
    func textViewDidChange(_ textView: UITextView) {
        
        // disable button if entered no text
        let spacing = CharacterSet.whitespacesAndNewlines
        if !messageTextView.text.trimmingCharacters(in: spacing).isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        
        
        // + paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            // redefine frame of MessageTxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            self.tableView.scrollToBottomRow()
            // move up tableView
            if textView.contentSize.height + keyboard.height + messageY >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
                
            }
        }
            
            // - paragraph
        else if textView.contentSize.height < textView.frame.size.height {
            
            // find difference to deduct
            let difference = textView.frame.size.height - textView.contentSize.height
            
            // redefine frame of MessageTxt
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // move donw tableViwe
            if textView.contentSize.height + keyboard.height + messageY > tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
        
        
        
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                if let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue{
                    
                    let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                    
                    if (endFrame.origin.y) >= UIScreen.main.bounds.size.height {
                     self.bottomViewContraits?.constant = 0.0
                        
                    } else {
                        
                        switch UIScreen.main.nativeBounds.height {
                        case 1136:
                            print("iPhone 5 or 5S or 5C")
                            self.bottomViewContraits?.constant = endFrame.size.height
                        case 1334:
                            print("iPhone 6/6S/7/8")
                            self.bottomViewContraits?.constant = endFrame.size.height
                        case 1920, 2208:
                            print("iPhone 6+/6S+/7+/8+")
                            self.bottomViewContraits?.constant = endFrame.size.height
                        case 2436:
                              print("iPhone X, XS")
                            self.bottomViewContraits?.constant = endFrame.size.height - 34
                        case 2688:
                            print("iPhone XS Max")
                            self.bottomViewContraits?.constant = endFrame.size.height - 34
                            
                        case 1792:
                            print("iPhone XR")
                             self.bottomViewContraits?.constant = endFrame.size.height - 34
                            
                        default:
                            print("unknown")
                            self.bottomViewContraits?.constant = endFrame.size.height
                        }
                        
                        
                    }
                    
                    
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: { self.view.layoutIfNeeded() },
                                   completion: nil)
                }
            }
        }
    }
    
    
    
}



extension Date {
    
    static func dateString(customString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: customString) ?? Date()
    }
    
    func getElapsedInterval() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: "\(month)/\(day)/\(year)") ?? Date()
        
    }
    
    
}




extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            guard self.indexPathIsValid(indexPath) else { return }
            
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
    
}



// EXTENSION TO SHOW TIME AGO DATES
extension UIViewController {
   
    
    func chatTime(_ date:Date,currentDate:Date) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 1){
            return date.string(with: "MMM dd, yyyy")
            
        } else if (components.month! >= 1) {
            
            return date.string(with: "MMMM yyyy")
            
        } else if (components.weekOfYear! >= 2) {
            
            return date.string(with: "MMMM yyyy")
            
        } else if (components.weekOfYear! >= 1){
            
            return "Last week"
            
        } else if (components.day! >= 2) {
            
            return date.string(with: "EEEE")
            
        } else if (components.day! >= 1){
            
            
            return "Yesterday"
            
        } else {
            let chatdate = date.string(with: "MMM dd, yyyy")
            let dateNow = Date().string(with: "MMM dd, yyyy")
            if dateNow != chatdate {
                return "Yesterday"
            }
            
            
            return "Today"
        }
        
    }
    
}



extension Date {
    func string(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
