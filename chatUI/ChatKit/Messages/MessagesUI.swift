//
//  MessagesUI.swift
//  chatUI
//
//  Created Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.


import UIKit

@objc protocol inputDelegate {
    @objc optional func sendText(text: String)
    @objc optional func SendImage(image: UIImage, caption: String?)
    @objc optional func SendAudio(url: URL)
    @objc optional func SendEmoji(emoji: String)
}

open class MessagesUI : UIView {
 
    /// ------------------------------------
    /// The data source for the messenger
    weak var dataSource: DataSource?
    weak var inputDelegate: inputDelegate?
    
    /// ------------------------------------
    public var currentUser: User!
    
    /// ------------------------------------
    
   lazy var tableView : UITableView = {
        let tbl = UITableView(frame: .zero, style: .grouped)
        tbl.backgroundColor = .clear
        tbl.separatorStyle = .none
        tbl.rowHeight = UITableView.automaticDimension
        tbl.estimatedRowHeight = 50
        tbl.delegate = self
        tbl.dataSource = self
        tbl.cellLayoutMarginsFollowReadableWidth = true
        tbl.contentInsetAdjustmentBehavior = .never
        tbl.allowsSelection = true
        tbl.keyboardDismissMode = keyboardDismissMode
        tbl.allowsMultipleSelection = false
        tbl.register(MessageTextCell.self, forCellReuseIdentifier: MessageTextCell.reuseIdentifier)
        tbl.register(MessageImageCell.self, forCellReuseIdentifier: MessageImageCell.reuseIdentifier)
        tbl.register(MessageCaptionCell.self, forCellReuseIdentifier: MessageCaptionCell.reuseIdentifier)
        tbl.register(MessageEmojiCell.self, forCellReuseIdentifier: MessageEmojiCell.reuseIdentifier)
        tbl.register(MessageAudioCell.self, forCellReuseIdentifier: MessageAudioCell.reuseIdentifier)
        return tbl
    }()
    
    
    /// ------------------------------------
   private lazy var messageTextView: GrowingTextView = {
        let tex = GrowingTextView()
        tex.placeholder = style.inputPlaceholder
        tex.minHeight = 35
        tex.maxHeight = 130
        tex.layer.cornerRadius = 13
        tex.backgroundColor = style.inputTextViewBackgroundColor
        tex.placeholderColor = style.inputPlaceholderTextColor
        tex.font = UIFont.systemFont(ofSize: 16)
        tex.enablesReturnKeyAutomatically = true
        tex.trimWhiteSpaceWhenEndEditing = true
        tex.tintColor = .black()
        tex.textContainerInset = .init(top: 7, left: 4, bottom: 7, right: 35)
        tex.delegate = self
        return tex
    }()
    
    /// ------------------------------------
    private var sendButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressSendTextButton), for: UIControl.Event.touchUpInside)
        button.setDimensions(width: 25, height: 25)
        button.isEnabled = true
        return button
     }()
    
    
    /// ------------------------------------
    private var mediaButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressSendFileButton), for: UIControl.Event.touchUpInside)
        
         return button
     }()
    
    /// ------------------------------------
    private var audioButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressSendAudioButton), for: UIControl.Event.touchUpInside)
         return button
     }()
    
    
    /// ------------------------------------
    private var emojiButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressSendEmojiButton), for: UIControl.Event.touchUpInside)
        button.setDimensions(width: 25, height: 25)
         return button
     }()
    
    /// ------------------------------------
    private var moreButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressSendMoreButton), for: UIControl.Event.touchUpInside)
         return button
     }()
    
    
    /// ------------------------------------
     var lineboardView: UIView = {
         let lineboardView = UIView()
         lineboardView.backgroundColor = .systemGray6
         return lineboardView
     }()
    
   /// ------------------------------------
    private var inputToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// ------------------------------------
    private var quickEmojiV: quickEmojiView = {
        let view = quickEmojiView()
        view.backgroundColor = .clear
        return view
    }()
    
    
    /// ------------------------------------
    private var recordAudioV: recordAudioView = {
        let view = recordAudioView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    /// ------------------------------------
     var typingBubble = TypingBubbleView()
    
    
    /// ------------------------------------
    open var stickersView: chatStickersUI = {
        let view = chatStickersUI()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    
    
    /// ------------------------------------
   private var iconsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    
    /// ------------------------------------
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    
    /// The style of the chat
    open var style: MessegesStyle {
        return ChatKit.Styles
    }
    

   private var buttonViewLeftConstraint = NSLayoutConstraint()
   private var textMore = true
   private var isKeybordShowing = false
   private var isAudioViewShowing = false
   private var keyboardHeight = CGFloat()

    // variable
    private var imagePicker: ImagePicker!
    var parentViewController: UIViewController? = nil
    /// The layout guide for the keyboard
    private let keyboardLayoutGuide = KeyboardLayoutGuide()
    private var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .interactive {
           didSet {
               tableView.keyboardDismissMode = keyboardDismissMode
           }
       }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = style.backgroundColor
        updateUIElements()
        setupUIElements()
        addObserver()
        
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Helpers
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    
    func updateUIElements() {}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor = style.backgroundColor
        self.keyboardHeight = KeyboardService.keyboardHeight()

        setupConstraints()
        self.imagePicker = ImagePicker(presentationController: parentViewController!, delegate: self)
        
    }

    
    // MARK: - SELECTIONS
    /// Send Text Button
    @objc private func didPressSendTextButton(_ sender: Any?) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        if sendButton.tag == 0 {
            quickEmoji()
        } else if sendButton.tag == 1 {
            sendText()
        } else {
            removeQuickEmoji()
        }

    }
    
    
    /// send a quick Emoji
    private func quickEmoji() {
        self.addSubview(quickEmojiV)
        quickEmojiV.delegate = self
        self.quickEmojiV.anchor(left: leftAnchor,bottom: stackView.topAnchor,right: rightAnchor,paddingBottom: 2)
        self.quickEmojiV.transform = self.quickEmojiV.transform.scaledBy(x: 0, y: 0)
        self.sendButton.tag = 2
        let previouTransform =  sendButton.transform
        UIView.animate(withDuration: 0.2,animations: {
        self.sendButton.setBackgroundImage(self.style.cancelIcon.withTintColor(self.style.inputIconsColor), for: .normal)
        self.sendButton.transform = self.sendButton.transform.scaledBy(x: 1.1, y: 1.1)
        self.quickEmojiV.transform  = .identity
        },completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.sendButton.transform  = previouTransform
                }
        })
        
    }
    
    /// remove a quick Emoji
    private func removeQuickEmoji() {
        sendButton.tag = 0
        let previouTransform =  sendButton.transform
        UIView.animate(withDuration: 0.2,animations: {
        self.sendButton.setBackgroundImage(self.style.quickEmojiIcon.withTintColor(self.style.inputIconsColor), for: .normal)
        self.sendButton.transform = self.sendButton.transform.scaledBy(x: 1.1, y: 1.1)
        self.quickEmojiV.transform = self.quickEmojiV.transform.scaledBy(x: 0.1, y: 0.1)
        },completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.quickEmojiV.transform = self.quickEmojiV.transform.scaledBy(x: 0.0, y: 0.0)
                self.quickEmojiV.removeFromSuperview()
                self.sendButton.transform  = previouTransform
                }
        })
        self.layoutIfNeeded()
    }
    
    /// send text message
    private func sendText() {
         self.textMore = true
         self.inputDelegate?.sendText?(text: messageTextView.text!)

         /// rest textview
         buttonViewLeftConstraint.constant = 0
         messageTextView.text = nil
        
        if style.isSupportQuickEmoji {
            sendButton.tag = 0
            let previouTransform =  sendButton.transform
            UIView.animate(withDuration: 0.2,animations: {
            self.sendButton.setBackgroundImage(self.style.quickEmojiIcon.withTintColor(self.style.inputIconsColor), for: .normal)
            self.sendButton.transform = self.sendButton.transform.scaledBy(x: 1.1, y: 1.1)
            },completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.sendButton.transform  = previouTransform
                    }
            })
        }

         self.layoutIfNeeded()
    }
    
    /// Send file Button
    @objc private func didPressSendFileButton(_ sender: Any?) {
        self.endEditing(true)
        self.imagePicker.present()
    }
       
    /// Send Emoji Button
    @objc private func didPressSendEmojiButton(_ sender: Any?) {
         self.sendButton.isEnabled = false
         self.audioButton.isEnabled = false
         self.mediaButton.isEnabled = false
         self.moreButton.isEnabled = false

        self.recordAudioV.isHidden = true
        self.stickersView.isHidden = true
         
        if isKeybordShowing {
             self.stickersView.isHidden = false
             self.endEditing(true)
             self.tableView.scrollToBottomRow(animated: false)
             self.layoutIfNeeded()
             
         } else {
             self.stickersView.isHidden = false
             self.tableView.scrollToBottomRow(animated: false)
             UIView.animate(withDuration: 0.3) {
              self.layoutIfNeeded()
           }
           
         }
    }
    
    /// Send audio Button
    @objc private func didPressSendAudioButton(_ sender: Any?) {
        self.sendButton.isEnabled = false
        self.emojiButton.isEnabled = false
        self.mediaButton.isEnabled = false
        self.moreButton.isEnabled = false
        
        
        recordAudioV.isHidden = true
        stickersView.isHidden = true
        
       if isKeybordShowing {
            self.recordAudioV.isHidden = false
            self.endEditing(true)
            self.tableView.scrollToBottomRow(animated: false)
            self.layoutIfNeeded()
            
        } else {
            self.recordAudioV.isHidden = false
            self.tableView.scrollToBottomRow(animated: false)
            UIView.animate(withDuration: 0.3) {
             self.layoutIfNeeded()
          }
          
        }
    
    }
    
    
    private func restButton() {
        self.sendButton.isEnabled = true
        self.emojiButton.isEnabled = true
        self.mediaButton.isEnabled = true
        self.moreButton.isEnabled = true
        self.audioButton.isEnabled = true
    }
    
    /// Send More Button
    @objc private func didPressSendMoreButton(_ sender: Any?) {}
    
}

extension MessagesUI {

   private func setupUIElements() {
        addSubview(tableView)
    
        /// ------------------------------------
        addSubview(stackView)
        stackView.addArrangedSubview(lineboardView)
        stackView.addArrangedSubview(inputToolbar)
        stackView.addArrangedSubview(recordAudioV)
        stackView.addArrangedSubview(stickersView)
        
       /// ------------------------------------
        recordAudioV.delegate = self
    
        /// ------------------------------------
        inputToolbar.addSubview(messageTextView)
        inputToolbar.addSubview(sendButton)
        inputToolbar.addSubview(iconsStackView)
        inputToolbar.addSubview(emojiButton)

        /// ------------------------------------
        iconsStackView.addArrangedSubview(moreButton)
        iconsStackView.addArrangedSubview(mediaButton)
        iconsStackView.addArrangedSubview(audioButton)
        
        /// ------------------------------------
        
       if style.isSupportQuickEmoji {
            sendButton.setBackgroundImage(style.quickEmojiIcon.withTintColor(style.inputIconsColor), for: .normal)
            sendButton.tag = 0
       } else {
            sendButton.setBackgroundImage(style.sendIcon.withTintColor(style.inputIconsColor), for: .normal)
            sendButton.tag = 1
        }
       
        /// ------------------------------------
        
        moreButton.setBackgroundImage(style.moreIcon.withTintColor(style.inputIconsColor), for: .normal)
        mediaButton.setBackgroundImage(style.mediaIcon.withTintColor(style.inputIconsColor), for: .normal)
        emojiButton.setBackgroundImage(style.stickersIcon.withTintColor(style.inputIconsColor), for: .normal)
        audioButton.setBackgroundImage(style.audioIcon.withTintColor(style.inputIconsColor), for: .normal)
     
    }
    
    
    private func setupConstraints() {

      
        
        typingBubble.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        typingBubble.typingBubble.startAnimating()
        self.tableView.tableFooterView = typingBubble
        
        /// ------------------------------------
        let height = self.safeAreaInsets.bottom
        recordAudioV.anchor(left: stackView.leftAnchor,right:stackView.rightAnchor,height:keyboardHeight - height)
        
        /// ------------------------------------
        stickersView.anchor(left: stackView.leftAnchor,right:stackView.rightAnchor,height:keyboardHeight - height)
        
        /// ------------------------------------
        inputToolbar.anchor(left: stackView.leftAnchor,right:stackView.rightAnchor)
        recordAudioV.isHidden = true
        stickersView.isHidden = true
       
        /// ------------------------------------
        let lineboardViewHeight = lineboardView.heightAnchor.constraint(equalToConstant: 0)
        lineboardViewHeight.isActive = true
        lineboardViewHeight.constant = 1
        
        /// ------------------------------------
        addLayoutGuide(keyboardLayoutGuide)
        stackView.anchor(top: tableView.bottomAnchor,left: leftAnchor,bottom: keyboardLayoutGuide.topAnchor,right: rightAnchor)
    
        /// ------------------------------------
        buttonViewLeftConstraint = iconsStackView.leftAnchor.constraint(equalTo: inputToolbar.leftAnchor)
        iconsStackView.anchor(bottom: messageTextView.bottomAnchor
               ,paddingBottom: 5)
        buttonViewLeftConstraint.isActive = true
        iconsStackView.spacing = 15
        moreButton.setDimensions(width: 25, height: 25)
        mediaButton.setDimensions(width: 25, height: 25)
        audioButton.setDimensions(width: 25, height: 25)
        
        /// ------------------------------------
        audioButton.isHidden = !style.isSupportAudio
        mediaButton.isHidden = !style.isSupportImages
        moreButton.isHidden = !style.isSupportMap
        
        
        /// ------------------------------------
        tableView.anchor(top: safeAreaLayoutGuide.topAnchor,left: leftAnchor,right: rightAnchor)
    
        /// ------------------------------------
        sendButton.anchor(bottom: messageTextView.bottomAnchor, right: inputToolbar.rightAnchor,paddingBottom: 5, paddingRight: 10)
        
        /// ------------------------------------
        emojiButton.anchor(bottom: messageTextView.bottomAnchor, right: messageTextView.rightAnchor,paddingBottom: 5, paddingRight: 5)
        
        /// ------------------------------------
        messageTextView.anchor(top: inputToolbar.topAnchor,left: iconsStackView.rightAnchor,bottom: inputToolbar.bottomAnchor,right: sendButton.leftAnchor, paddingTop: 5,paddingLeft: 10,paddingBottom: 5,paddingRight: 5)
        
        /// ------------------------------------
        iconsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        

      
    }
    
    // register observers
    private func addObserver() {
        /// keyboard will Show
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        /// keyboard will Show
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // keyboard Will show
    @objc open dynamic func keyboardWillShow(_ notification: Notification) {
           self.restButton()
           self.isKeybordShowing = true
           self.recordAudioV.isHidden = true
           self.stickersView.isHidden = true
           self.layoutIfNeeded()
           self.tableView.scrollToBottomRow(animated: false)
        
       }

    // keyboard Will hide
    @objc open dynamic func keyboardWillHide(_ notification: Notification) {
         self.isKeybordShowing = false
         self.layoutIfNeeded()
       }
    
    
}


extension MessagesUI: quickEmojiDelegate, recordDelegate {
    func AudioFile(_ url: URL) {
        self.messageTextView.becomeFirstResponder()
        self.inputDelegate?.SendAudio?(url: url)
    }
    
    func EmojiTapped(index: Int) {
        self.inputDelegate?.SendEmoji?(emoji: quickEmojiV.quickEmojiArray[index])
 
         // rest view
         sendButton.tag = 0
         let previouTransform =  sendButton.transform
         UIView.animate(withDuration: 0.2,animations: {
        self.sendButton.setBackgroundImage(self.style.quickEmojiIcon.withTintColor(self.style.inputIconsColor), for: .normal)
         self.sendButton.transform = self.sendButton.transform.scaledBy(x: 1.1, y: 1.1)
         self.quickEmojiV.transform = self.quickEmojiV.transform.scaledBy(x: 0.1, y: 0.1)
         },completion: { _ in
             UIView.animate(withDuration: 0.2) {
                 self.quickEmojiV.transform = self.quickEmojiV.transform.scaledBy(x: 0.0, y: 0.0)
                 self.quickEmojiV.removeFromSuperview()
                 self.sendButton.transform  = previouTransform
                 }
         })
         self.layoutIfNeeded()
    }

}

extension MessagesUI: ImagePickerDelegate {
    public func didSelect(image: UIImage?, caption: String?) {
        guard let image = image else { return }
        self.inputDelegate?.SendImage?(image: image, caption: caption)
    }
}


extension MessagesUI: GrowingTextViewDelegate, UITextViewDelegate {
    
    // Mark: Keyboard Configure
    // while writing something
    public func textViewDidChange(_ textView: UITextView) {
       /// disable button if entered has no text
        guard let text = textView.text else { return }
         if text.count == 0 {
            buttonViewLeftConstraint.constant = 0
            
            if style.isSupportQuickEmoji {
                sendButton.tag = 0
                UIView.animate(withDuration: 0.2,animations: {
                self.sendButton.setBackgroundImage(self.style.quickEmojiIcon.withTintColor(self.style.inputIconsColor), for: .normal)
                self.sendButton.transform = self.sendButton.transform.scaledBy(x: 1.1, y: 1.1)
                },completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.sendButton.transform  = .identity
                        self.textMore = true
                        }
                })
            }

            
            self.layoutIfNeeded()
         } else {
            buttonViewLeftConstraint.constant = -iconsStackView.frame.width
            if style.isSupportQuickEmoji {
                sendButton.tag = 1
                if textMore == true {
                    UIView.animate(withDuration: 0.2,animations: {
                    self.sendButton.setBackgroundImage(self.style.sendIcon.withTintColor(self.style.inputIconsColor), for: .normal)
                    self.sendButton.transform = self.sendButton.transform.scaledBy(x: 1.1, y: 1.1)
                    },completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            self.sendButton.transform  = .identity
                            self.textMore = false
                            }
                    })
                }
            }


            self.tableView.scrollToBottom(animated: false)
            self.tableView.layoutIfNeeded()
            self.tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: false)
             self.layoutIfNeeded()
           
         }

     }
    
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    public func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.layoutIfNeeded()
            }, completion: { (completed) in
        })
    }
}
