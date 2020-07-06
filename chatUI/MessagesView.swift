//
//  MessagesView.swift
//  chatUI
//
//  Created Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.


import UIKit


class chatUI: MessagesUI {
    override var style: MessegesStyle {
        var style = ChatKit.Styles
            style.showingAvataer = false
//          style.isSupportAudio = false
//          style.isSupportImages = false
//          style.isSupportQuickEmoji = false

        return style
    }
}

class MessagesView: UIViewController {
    
    
    let MeFaris = User(userId: "1", fullname: "Faris", avatar: #imageLiteral(resourceName: "audio_icon"))
    let Tim = User(userId: "2", fullname: "Tim", avatar: #imageLiteral(resourceName: "emoji_3"))
    let goh = User(userId: "3", fullname: "goh", avatar: #imageLiteral(resourceName: "emoji_3"))
    
    let image1 = UIImage(named: "image1")
    let image2 = UIImage(named: "image2")
    let image3 = UIImage(named: "me")
    
    private var ui = chatUI()
    var viewModel = MessagesViewModel()

    override func viewWillDisappear(_ animated: Bool) {
        view.layoutIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        view.layoutIfNeeded()
    }
    
     var messagesData = [[Messages]]()
    
    
 
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    override func loadView() {
        ui.parentViewController = self
        ui.dataSource = self
        ui.inputDelegate = self
        view = ui
        ui.currentUser = MeFaris
        setNavigationBar()
        // test array
         let messagesFromServer = [
            
            Messages(objectId: "1331", user: MeFaris, image: image1!, text: "text", createdAt: Date.dateString(customString: "05/22/2019"), isIncoming: false),
            
            Messages(objectId: "1323", user: MeFaris, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/22/2019"), isIncoming: false),
            
            Messages(objectId: "1323", user: Tim, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/22/2019"), isIncoming: true),
            Messages(objectId: "1323", user: Tim, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/23/2019"), isIncoming: true),
            
            Messages(objectId: "1323", user: goh, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/23/2019"), isIncoming: true),
            
            Messages(objectId: "1323", user: goh, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/23/2019"), isIncoming: true),
            
            Messages(objectId: "1323", user: goh, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/23/2019"), isIncoming: true),
            
            Messages(objectId: "1323", user: goh, text: "Lorem Ipsum is simply", createdAt: Date.dateString(customString: "05/23/2019"), isIncoming: true),
         ]
        
        
        MessagesViewModel.shared.GroupedMessages(Messages: messagesFromServer) { (messages) in
             self.messagesData = messages
            self.ui.tableView.reloadData()
             DispatchQueue.main.async {
                self.ui.tableView.scrollToBottom(animated: false)
                self.ui.tableView.layoutIfNeeded()
                self.ui.tableView.setContentOffset(CGPoint(x: 0, y: self.ui.tableView.contentSize.height - self.ui.tableView.frame.height - 20), animated: false)
    
             }
         }
        
        
    }
    

    func setNavigationBar() {
        navigationItem.title = "Messages"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.tintColor = .systemBackground
    }
    
    func insert(_ NewMessages: Messages) {
        
         let diff = Calendar.current.dateComponents([.day], from: Date(), to: ( messagesData.last?.last?.createdAt)!)
          if diff.day == 0 {
             MessagesViewModel.shared.object[self.messagesData.count - 1].append(NewMessages)
               self.messagesData[self.messagesData.count - 1].append(NewMessages)
               self.ui.tableView.reloadData()
               DispatchQueue.main.async {
                    self.ui.tableView.scrollToBottom(animated: false)
                    self.ui.tableView.layoutIfNeeded()
                    self.ui.tableView.setContentOffset(CGPoint(x: 0, y: self.ui.tableView.contentSize.height - self.ui.tableView.frame.height - 20), animated: false)
               }
             
         } else {
             MessagesViewModel.shared.object.insert([NewMessages], at: self.messagesData.count)
             self.messagesData.insert([NewMessages], at: self.messagesData.count)
             self.ui.tableView.reloadData()
             DispatchQueue.main.async {
                 self.ui.tableView.scrollToBottom(animated: false)
                 self.ui.tableView.layoutIfNeeded()
                 self.ui.tableView.setContentOffset(CGPoint(x: 0, y: self.ui.tableView.contentSize.height - self.ui.tableView.frame.height - 20), animated: false)
             }
         }
    }

    
}


extension MessagesView: DataSource {
    func message(for indexPath: IndexPath) -> Messages {
        return self.messagesData[indexPath.section][indexPath.row]
    }
    
    func headerTitle(for section: Int) -> [Messages] {
        return self.messagesData[section]
    }
    
    func numberOfSections() -> Int {
        return self.messagesData.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return self.messagesData[section].count
    }
    
}

extension MessagesView: inputDelegate {
    
    func sendText(text: String) {
        print("sadfdf")
        let now = Date()
        let NewMessages = Messages(objectId: "12321", user: MeFaris, text: text, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
        
    }
    
    func SendAudio(url: URL) {
        let now = Date()
        let NewMessages = Messages(objectId: "12321", user: MeFaris, audio: url, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
    }
    
    func SendEmoji(emoji: String) {
        let now = Date()
        let NewMessages = Messages(objectId: "23223", user: MeFaris, stickerName: emoji, StickerType: .emoji, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
    }
    
    func SendImage(image: UIImage, caption: String?) {
        let now = Date()
        if caption == nil {
            let NewMessages = Messages(objectId: "324243", user: MeFaris, image: image, createdAt: now, isIncoming: false)
            self.insert(NewMessages)
        } else {
            let NewMessages = Messages(objectId: "324243", user: MeFaris, image: image, text: caption, createdAt: now, isIncoming: false)
            self.insert(NewMessages)
        }
        
    }
}
