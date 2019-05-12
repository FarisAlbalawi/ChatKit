//
//  chatView.swift
//  chatUI
//
//  Created by Faris Albalawi on 5/12/19.
//  Copyright © 2019 Faris Albalawi. All rights reserved.
//

import UIKit

class chatView: UIViewController {

    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomViewContraits: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var isOnlineView: UIView!
    @IBOutlet weak var itemImag: UIImageView!
    
    
     var chatMessages = [[ChatMessage]]()
    
    var isIncoming = true
    
    var messagesFromServer = [
        ChatMessage(text: "hey thery", isIncoming: true, date: Date.dateString(customString: "1/05/2019")),
        ChatMessage(text: "how are you doing?", isIncoming: true, date: Date.dateString(customString: "01/05/2019")),
        ChatMessage(text: "I'm doing very well!! how about u?", isIncoming: false, date: Date.dateString(customString: "05/11/2019")),
        ChatMessage(text: "I'm Good", isIncoming: true, date: Date.dateString(customString: "05/11/2019")),
    ]
    
    

  
    // variable
    var keyboard = CGRect()
    var messageY : CGFloat = 0
    
    fileprivate let cellId = "id123"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.isTranslucent = false
        
        // tableview cell
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0);
     
        // Initial setup
        self.edgesForExtendedLayout = UIRectEdge()
        
        
        
        // custom
        itemImag.layer.cornerRadius = itemImag.bounds.width / 2.0
        itemImag.clipsToBounds = true
        isOnlineView.layer.cornerRadius = isOnlineView.bounds.width / 2.0
        isOnlineView.layer.borderWidth = 2
        isOnlineView.layer.borderColor = UIColor.white.cgColor
        
    
        
        //  keyboard Will Show
        NotificationCenter.default.addObserver(self, selector: #selector(chatView.keyboardWillShow(_:)), name:
            UIApplication.keyboardWillChangeFrameNotification, object: nil)
        
     
        // call functions
        self.textViewSettings()
        self.tableViewSettings()
        self.keyboardSettings()
    
        GroupedMessages()
        
        
        
        // Do any additional setup after loading the view.
    }
    

    
    fileprivate func GroupedMessages() {
      
        let groupedMessages = Dictionary(grouping: messagesFromServer) { (element) -> Date in
            return element.date.getElapsedInterval()
        }
        
        // provide a sorting for your keys somehow
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            chatMessages.append(values ?? [])
        }
        
    }
    
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: now)
        
        
        let messagesFromServer2 = ChatMessage(text: "\(messageTextView.text!)", isIncoming: isIncoming, date: Date.dateString(customString: "\(dateString)"))
        
         let messagesFromServer = [ChatMessage(text: "\(messageTextView.text!)", isIncoming: isIncoming, date: Date.dateString(customString: "\(dateString)"))]
      
        
        
        
        if self.chatMessages.count != 0 {
            
            if let firstMessageInSection = self.chatMessages[self.chatMessages.count - 1].last {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let dateString = dateFormatter.string(from: firstMessageInSection.date)
                let dateString2 = dateFormatter.string(from: messagesFromServer2.date)
                if dateString == dateString2 {
                self.chatMessages[self.chatMessages.count - 1].append(contentsOf: messagesFromServer)
                    self.tableView.reloadData()
                    self.tableView.scrollToBottomRow()
                    self.messageTextView.text = ""
                    
                    
                } else {
                    self.chatMessages.insert(messagesFromServer, at: self.chatMessages.count)
                    
                    self.tableView.reloadData()
                    self.tableView.scrollToBottomRow()
                    self.messageTextView.text = ""
                    
                    
                    
                }
            }
            
            
        } else {
            self.chatMessages.insert(messagesFromServer, at: self.chatMessages.count)
            
            self.tableView.reloadData()
            self.tableView.scrollToBottomRow()
            self.messageTextView.text = ""
            
        }
        
        if isIncoming {
            isIncoming = false
        } else {
             isIncoming = true
        }
        
      
    }
    
    
    


}


extension chatView: UITableViewDelegate, UITableViewDataSource {
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let date = Date()
            let dateString = chatTime(firstMessageInSection.date, currentDate: date)
            let label = DateHeader()
            label.text = dateString
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            return containerView
            
        }
        return nil
    }
    

     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
        let chatMessage = chatMessages[indexPath.section][indexPath.row]
        cell.chatMessage = chatMessage
        return cell
    }
}
