//
//  MessagesView.swift
//  chatUI
//
//  Created Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.


import UIKit


class chatUI: MessagesUI {
    var sgView = chatStickersView()
    
    override var style: MessegesStyle {
        var style = ChatKit.Styles
            style.showingAvataer = true
//          style.isSupportAudio = false
//          style.isSupportImages = false
//          style.isSupportQuickEmoji = false

        return style
    }
    
   override func updateUIElements() {
        sgView.backgroundColor = .systemGray6
        self.stickersView = sgView
    }
    
}

class MessagesView: UIViewController {
    
    
    let userTim = User(userId: "1", displayname: "Time", avatar: #imageLiteral(resourceName: "audio_icon"))
    let userFaris = User(userId: "2", displayname: "Faris", avatar: #imageLiteral(resourceName: "emoji_3"))
    let goh = User(userId: "3", displayname: "goh", avatar: #imageLiteral(resourceName: "emoji_3"))
    
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
        ui.sgView.stickerGifDelegate = self
        ui.cellDelegate = self
        view = ui
    
        ui.currentUser = userTim
        setNavigationBar()
        // test array
         let messagesFromServer = [
            
            Messages(objectId: "1331", user: userTim, image: image1!, text: "text 4125388166", createdAt: Date.dateString(customString: "05/22/2019"), isIncoming: false),
            
            Messages(objectId: "1323", user: userTim, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry 4125388166", createdAt: Date.dateString(customString: "05/22/2019"), isIncoming: false),
            
            Messages(objectId: "1323", user: goh, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry 4125388166", createdAt: Date.dateString(customString: "05/22/2019"), isIncoming: true),
            Messages(objectId: "1323", user: goh, text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", createdAt: Date.dateString(customString: "05/23/2019"), isIncoming: true),
            
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
        
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.ui.setUsersTyping([self.userFaris])
            self.ui.tableView.setContentOffset(CGPoint(x: 0, y: self.ui.tableView.contentSize.height - self.ui.tableView.frame.height), animated: true)
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let now = Date()
            let NewMessages = Messages(objectId: "12321", user: self.userFaris, text: "Welcome to chatKit ❤️", createdAt: now, isIncoming: true)
                self.insert(NewMessages)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
           self.ui.setUsersTyping([])
           let now = Date()
           let NewMessages = Messages(objectId: "12321", user: self.userFaris, text: "I'm still working on it, I will get it done as soon as possible.", createdAt: now, isIncoming: true)
             self.insert(NewMessages)
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
               let loc =  self.ui.tableView.contentOffset
                 UIView.performWithoutAnimation {
                   self.ui.tableView.reloadData()
                   self.ui.tableView.layoutIfNeeded()
                   self.ui.tableView.beginUpdates()
                   self.ui.tableView.endUpdates()
                   self.ui.tableView.layer.removeAllAnimations()
                 }
               self.ui.tableView.setContentOffset(loc, animated: true)
               DispatchQueue.main.async {
                    self.ui.tableView.scrollToBottom(animated: true)
                    self.ui.tableView.layoutIfNeeded()
                    self.ui.tableView.setContentOffset(CGPoint(x: 0, y: self.ui.tableView.contentSize.height - self.ui.tableView.frame.height - 20), animated: true)
               }
             
         } else {
             MessagesViewModel.shared.object.insert([NewMessages], at: self.messagesData.count)
             self.messagesData.insert([NewMessages], at: self.messagesData.count)
             
            let loc =  self.ui.tableView.contentOffset
              UIView.performWithoutAnimation {
                self.ui.tableView.reloadData()
                self.ui.tableView.layoutIfNeeded()
                self.ui.tableView.beginUpdates()
                self.ui.tableView.endUpdates()
                self.ui.tableView.layer.removeAllAnimations()
              }
             self.ui.tableView.setContentOffset(loc, animated: true)
             DispatchQueue.main.async {
                 self.ui.tableView.scrollToBottom(animated: true)
                 self.ui.tableView.layoutIfNeeded()
                 self.ui.tableView.setContentOffset(CGPoint(x: 0, y: self.ui.tableView.contentSize.height - self.ui.tableView.frame.height), animated: true)
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

// MARK: - MessageLabelDelegate

extension MessagesView: MessageCellDelegate {
    func contextLabel(_ sender: ContextLabel, textFontForLinkResult linkResult: LinkResult) -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    func contextLabel(_ sender: ContextLabel, foregroundColorForLinkResult linkResult: LinkResult) -> UIColor {
        if sender.isIncoming {
            switch linkResult.detectionType {
                case .none:
                    return sender.textColor
                case .userHandle:
                    return .setColor(dark: .blue, light: .blue)
                case .hashtag:
                    return .setColor(dark: .blue, light: .blue)
                case .url:
                    return .setColor(dark: .blue, light: .blue)
                case .email:
                    return .setColor(dark: .blue, light: .blue)
                case .phoneNumber:
                    return .setColor(dark: .blue, light: .blue)
                }
        } else {
            switch linkResult.detectionType {
                case .none:
                    return sender.textColor
                case .userHandle:
                    return .setColor(dark: .yellow, light: .yellow)
                case .hashtag:
                    return .setColor(dark: .yellow, light: .yellow)
                case .url:
                    return .setColor(dark: .yellow, light: .yellow)
                case .email:
                    return .setColor(dark: .yellow, light: .link)
                case .phoneNumber:
                    return .setColor(dark: .yellow, light: .yellow)
                }
        }

    }
    
    func contextLabel(_ sender: ContextLabel, foregroundHighlightedColorForLinkResult linkResult: LinkResult) -> UIColor {
        return sender.textColor
    }
    
    func contextLabel(_ sender: ContextLabel, underlineStyleForLinkResult linkResult: LinkResult) -> NSUnderlineStyle {
        switch linkResult.detectionType {
        case .none:
            return []
        case .userHandle:
            return .single
        case .hashtag:
            return .single
        case .url:
            return .single
        case .email:
            return .single
        case .phoneNumber:
            return .single
        }
        
    }
    
    func contextLabel(_ sender: ContextLabel, modifiedAttributedString attributedString: NSAttributedString) -> NSAttributedString {
        return attributedString
    }
    
    func contextLabel(_ sender: ContextLabel, didTouchWithTouchResult touchResult: TouchResult) {
         guard let textLink = touchResult.linkResult else { return }
         switch touchResult.state {
           case .ended:
               switch textLink.detectionType {
               case .url:
                   print("url \(textLink.text)")
               case .email:
                   print("email \(textLink.text)")
               case .phoneNumber:
                   print("phoneNumber \(textLink.text)")
               case .hashtag:
                  print("hashtag \(textLink.text)")
               case .userHandle:
                  print("userHandle \(textLink.text)")
               case .none:
                print("none")
            }
               
           default:
               break
           }
    }
    
    func contextLabel(_ sender: ContextLabel, didCopy text: String?) {
      
        
    }
    


}


extension MessagesView: inputDelegate {
    
    func startTyping() {
        print("Debug: start Typing")
    }
    
    func stopTyping() {
        print("Debug: stop Typing")
    }
    
    func sendText(text: String) {
        let now = Date()
        let NewMessages = Messages(objectId: "12321", user: userTim, text: text, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
        
    }
    
    func SendAudio(url: URL) {
        let now = Date()
        let NewMessages = Messages(objectId: "12321", user: userTim, audio: url, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
    }
    
    func SendEmoji(emoji: String) {
        let image = UIImage(named: emoji)!
        let now = Date()
        let NewMessages = Messages(objectId: "23223", user: userTim, sticker: image, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
    }
    
    func SendImage(image: UIImage, caption: String?) {
        let now = Date()
        if caption == nil {
            let NewMessages = Messages(objectId: "324243", user: userTim, image: image, createdAt: now, isIncoming: false)
            self.insert(NewMessages)
        } else {
            let NewMessages = Messages(objectId: "324243", user: userTim, image: image, text: caption, createdAt: now, isIncoming: false)
            self.insert(NewMessages)
        }
        
    }
}
extension MessagesView: stickersGifDelegate {
    func sendSticker(name: String) {
        let image = UIImage(named: name)!
        let now = Date()
        let NewMessages = Messages(objectId: "23223", user: userTim, sticker: image, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
    }
    func SendGif(name: String) {
        let image = UIImage.gif(name: name)!
        let now = Date()
        let NewMessages = Messages(objectId: "23223", user: userTim, sticker: image, createdAt: now, isIncoming: false)
        self.insert(NewMessages)
    }
}
