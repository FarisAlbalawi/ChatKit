//
//  MessagesViewModel.swift
//  chatUI
//
//  Created Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.


import Foundation
import UIKit


class MessagesViewModel {
    static let shared = MessagesViewModel()
    
    var object = [[Messages]]()
    
    func GroupedMessages(Messages: [Messages], completion: @escaping([[Messages]]) -> Void) {
        object.removeAll()
        let groupedMessages = Dictionary(grouping: Messages) { (element) -> Date in
            return element.createdAt.getElapsedInterval()
        }
        // provide a sorting for your keys somehow
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            object.append(values ?? [])
            completion(object)
        }
    }
    
    func getPositionInBlockForMessageAtIndex(_ section: Int, _ index: Int) -> PositionInBlock {
        let message = object[section][index]
        if let beforeItemMessage = object[section].item(before: index),
            let afterItemMessage = object[section].item(after: index) {
            if beforeItemMessage.user.userId == message.user.userId
                && message.isIncoming == afterItemMessage.isIncoming {
                return .center
            }
            
            if beforeItemMessage.user.userId == message.user.userId {
                return .bottom
            }
            
            if message.user.userId == afterItemMessage.user.userId {
                return .top
            }
            
            return .single
        }
        
        if let beforeItemMessage = object[section].item(before: index) {
            if beforeItemMessage.user.userId == message.user.userId {
                return .bottom
            }
            return .single
        }
        
        if let afterItemMessage = object[section].item(after: index) {
            if afterItemMessage.user.userId == message.user.userId {
                return .top
            }
            
            return .single
        }
        
        return .single
    }
    
    
    func chatTime(_ date:Date,currentDate:Date) -> String {
         let calendar = Calendar.current
         let now = currentDate
         let earliest = (now as NSDate).earlierDate(date)
         let latest = (earliest == now) ? date : now
         let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
         
         if (components.year! >= 1){
             return date.string(with: "MMM dd, yyyy")
             
         } else if (components.month! >= 1) {
             
             return date.string(with: "MMM dd, yyyy")
             
         } else if (components.weekOfYear! >= 2) {
             
             return date.string(with: "MMM dd, yyyy")
             
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
