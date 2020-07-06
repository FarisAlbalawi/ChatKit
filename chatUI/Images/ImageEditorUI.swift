//
//  ImageEditorUI.swift
//  chatUI
//
//  Created Faris Albalawi on 4/23/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.


import UIKit


class ImageEditorUI : UIView {
    
   weak var delegate: ImagePickerDelegate?
   weak var presentationController: UIViewController?
   weak var presentationController2: UIViewController?
    
   private let mainView: UIView = {
        let mainView = UIView()
        mainView.backgroundColor = .clear
        mainView.layer.cornerRadius = 25
        mainView.layer.masksToBounds = true
        return mainView
    }()
    
    let toolsView: ToolsView = {
        let toolsView = ToolsView()
        toolsView.layer.masksToBounds = true
        toolsView.backgroundColor = .clear
        return toolsView
    }()
    
    var tempImageView: UIImageView = {
         let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFit
         imageView.backgroundColor = .red
         imageView.clipsToBounds = true
         imageView.isUserInteractionEnabled = true
         return imageView
         
     }()
    
   private let cropPickerViews: CropPickerView = {
        let cropPickerViews = CropPickerView()
        cropPickerViews.translatesAutoresizingMaskIntoConstraints = false
        cropPickerViews.backgroundColor = .clear
        cropPickerViews.cropLineColor = UIColor.gray
        cropPickerViews.scrollBackgroundColor = .clear
        cropPickerViews.imageBackgroundColor = .clear
        cropPickerViews.dimBackgroundColor = UIColor(white: 0, alpha: 0.5)
        cropPickerViews.scrollMinimumZoomScale = 1
        cropPickerViews.scrollMaximumZoomScale = 2
        return cropPickerViews
    }()
    
    private lazy var messageTextView: GrowingTextView = {
         let tex = GrowingTextView()
         tex.tag = 101
         tex.placeholder = "Add a caption"
         tex.minHeight = 35
         tex.maxHeight = 130
         tex.layer.cornerRadius = 13
         tex.backgroundColor = .black
         tex.placeholderColor = .systemGray4
         tex.font = UIFont.systemFont(ofSize: 16)
         tex.enablesReturnKeyAutomatically = true
         tex.trimWhiteSpaceWhenEndEditing = true
         tex.tintColor = .black()
         tex.textContainerInset = .init(top: 7, left: 4, bottom: 7, right: 4)
         tex.delegate = self
         return tex
     }()
    
    private var sendButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "send_icon")?.withTintColor(.mainBlue), for: .normal)
        button.addTarget(self, action: #selector(didPressSendButton), for: UIControl.Event.touchUpInside)
        button.setDimensions(width: 30, height: 30)
        return button
     }()
    
    
     var cancelButton: UIButton = {
        let button = UIButton()
        let icon = UIImage(named: "cancel_icon")
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(didPressCancelButton), for: UIControl.Event.touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setDimensions(width: 35, height: 35)
        return button
     }()
    
     var inputToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var image: UIImage?{
        didSet {
            let img = image?.resizeImage(targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            tempImageView.image = img
            guard let height = img?.size.height else { return }
            imageViewHeight.constant = height
            drawViewHeight.constant = height
            self.layoutIfNeeded()
        }
    }
    
    
    
    
    let deleteView : UIView = {
        let deleteView = UIView()
        deleteView.backgroundColor = UIColor.red
        deleteView.alpha = 0.5
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.layer.cornerRadius = 50 / 2
        deleteView.layer.borderWidth = 1.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        let icons = UIImageView()
        icons.frame.size = CGSize(width: 30, height: 30)
        icons.image = UIImage(named: "delete")
        icons.contentMode = .scaleAspectFit
        deleteView.addSubview(icons)
        icons.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icons.heightAnchor.constraint(equalToConstant: 25),
            icons.widthAnchor.constraint(equalToConstant: 25),
            icons.centerXAnchor.constraint(equalTo: deleteView.centerXAnchor),
            icons.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor)
            ])
        
        return deleteView
    }()
    
    var lastPanPoint: CGPoint?
    var imageViewToPan: UIImageView?
    var bottomSheetIsVisible = false
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var isCaption = true
    private let drawView: TouchDrawView = {
        let drawView = TouchDrawView()
        drawView.backgroundColor = .clear
        return drawView
        
    }()
    
    var inputToolbarBottomConstraint = NSLayoutConstraint()
    private var drawViewColor: UIColor = .black
    private var imageViewHeight = NSLayoutConstraint()
    private var drawViewHeight = NSLayoutConstraint()
  
    var StickerVC: StickerViewController!
    
     public var stickers : [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for i in 100...110 {
                 stickers.append(i.description)
             }
        
        StickerVC = StickerViewController(nibName: nil, bundle: Bundle(for: StickerViewController.self))
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
          self.addGestureRecognizer(tap)
          addObserver()
          setupUIElements()
       

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
          setupConstraints()
        
    }
    
}

extension ImageEditorUI {

    // register observers
    private func addObserver() {
   
        /// keyboard will Show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        /// keyboard Will Hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // keyboard Will ChangeFrame ( hide / show )
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
           //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
          self.addGestureRecognizer(tap)
        if isCaption {
            if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
                if keyboardHeight > 0 {
                    inputToolbar.backgroundColor = .darkBackground
                    keyboardHeight = keyboardHeight - self.safeAreaInsets.bottom
                } else {
                    inputToolbar.backgroundColor = .clear
                }
                    inputToolbarBottomConstraint.constant = -keyboardHeight
            
                self.layoutIfNeeded()
            }
        } else {
            if notification.name == UIResponder.keyboardWillHideNotification {
                self.toolsView.setBackTextToolsUI()
                self.cancelButton.isHidden = false
                self.inputToolbar.isHidden = false
            }
            
        }

    }
    
    
    private func setupUIElements() {
        // arrange subviews
        drawView.image = nil
        drawView.isUserInteractionEnabled = false
        drawView.delegate = self
        drawView.setWidth(5.0)
        drawView.setColor(.red)
        toolsView.undoButton.isEnabled = false
        toolsView.redoButton.isEnabled = false
        toolsView.DTDelegate = self
        
        addSubview(mainView)
        mainView.addSubview(tempImageView)
        addSubview(toolsView)
        addSubview(cancelButton)
        tempImageView.addSubview(drawView)
        
        addSubview(inputToolbar)
        inputToolbar.addSubview(messageTextView)
        inputToolbar.addSubview(sendButton)
        
        mainView.anchor(top: safeAreaLayoutGuide.topAnchor,left: leftAnchor,bottom: safeAreaLayoutGuide.bottomAnchor,right: rightAnchor)
        
        mainView.backgroundColor = .darkBackground
        
        tempImageView.center(inView: self)
        imageViewHeight = tempImageView.heightAnchor.constraint(equalToConstant: 0)
        imageViewHeight.isActive = true
        tempImageView.anchor(left: leftAnchor,right: rightAnchor)
        drawView.center(inView: self)
        drawView.anchor(left: leftAnchor,right: rightAnchor)
        drawViewHeight = drawView.heightAnchor.constraint(equalToConstant: 0)
        drawViewHeight.isActive = true
        addSubview(deleteView)
        deleteView.isHidden = true
       
        self.layoutIfNeeded()
    }
    
    
    private func setupConstraints() {
        // add constraints to subviews
        toolsView.anchor(top: safeAreaLayoutGuide.topAnchor,left: leftAnchor,right: rightAnchor,paddingTop: 10,paddingLeft: 10,paddingRight: 10, height: 60)

         // add constraints to inputToolbar
        inputToolbar.anchor(left: leftAnchor,right: rightAnchor)
        inputToolbarBottomConstraint = inputToolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,constant: 0)
        inputToolbarBottomConstraint.isActive = true
        
        sendButton.anchor(bottom: messageTextView.bottomAnchor, right: inputToolbar.rightAnchor,paddingBottom: 3, paddingRight: 10)
        
        messageTextView.anchor(top: inputToolbar.topAnchor,left: inputToolbar.leftAnchor,bottom: inputToolbar.bottomAnchor,right: sendButton.leftAnchor, paddingTop: 5,paddingLeft: 10,paddingBottom: 5,paddingRight: 10)
        
        cancelButton.anchor(top: safeAreaLayoutGuide.topAnchor,left: leftAnchor,paddingTop: 10,paddingLeft: 10)
        
        
        
        // deleteView layout
        NSLayoutConstraint.activate([
            deleteView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,constant: -4),
            deleteView.heightAnchor.constraint(equalToConstant: 50),
            deleteView.widthAnchor.constraint(equalToConstant: 50),
            deleteView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    
        
   
    }
    
    // MARK: - SELECTIONS
    
    /// Send Text Button
    @objc private func didPressSendButton(_ sender: Any?) {
        self.presentationController2?.dismiss(animated: true, completion: nil)
        if messageTextView.text.count == 0 {
            let img = tempImageView.asImage()
            self.delegate?.didSelect(image: img, caption: nil)
        } else {
            let img = tempImageView.asImage()
            self.delegate?.didSelect(image: img, caption: messageTextView.text)
        }
        
    }
    
    @objc private func didPressCancelButton(_ sender: Any?) {
        self.presentationController?.dismiss(animated: true, completion: nil)
    }
    
    // Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    
}

extension ImageEditorUI: TouchDrawViewDelegate, ToolsDelegate {
    func showStickers() {
        endEditing(true)
        addBottomSheetView()
    }
    
    func hideStickers() {
        endEditing(true)
        removeBottomSheetView()
    }
    
    func textTapped() {
        endEditing(true)
        cancelButton.isHidden = true
        inputToolbar.isHidden = true
        isCaption = false
        let textView = UITextView(frame: CGRect(x: 0, y: self.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
        //Text Attributes
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 40)
        textView.textColor = drawViewColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.tempImageView.addSubview(textView)
       
   
        addGestures(view: textView)
        activeTextView = textView
        textView.becomeFirstResponder()
    }
    
    func stopText() {
        endEditing(true)
        cancelButton.isHidden = false
        inputToolbar.isHidden = false
        tempImageView.isUserInteractionEnabled = true
        isCaption = true
        activeTextView = nil
        self.endEditing(true)
    }
    
    
    
    func startCropping() {
        endEditing(true)
        self.cancelButton.isHidden = true
        self.cropPickerViews.image = image
        mainView.addSubview(cropPickerViews)
        cropPickerViews.anchor(top: mainView.topAnchor,left: mainView.leftAnchor,bottom: mainView.bottomAnchor,right: mainView.rightAnchor,paddingTop: 50,paddingLeft: 50,paddingBottom: 50,paddingRight: 50)
        self.tempImageView.isHidden = true
        self.inputToolbar.isHidden = true
        self.layoutIfNeeded()
    }
    
    func doneCropping() {
        endEditing(true)
        self.cropPickerViews.crop { (error, image) in
            if let error = (error as NSError?) {
                  print(error.domain)
                return
            }
            
            self.cancelButton.isHidden = false
            self.image = image
            self.tempImageView.isHidden = false
            self.inputToolbar.isHidden = false
            self.cropPickerViews.removeFromSuperview()
            self.layoutIfNeeded()
              
        }
    }
    
    
    func startDrwing() {
        endEditing(true)
        self.drawView.setColor(drawViewColor)
        self.drawView.isUserInteractionEnabled = true
        self.tempImageView.isUserInteractionEnabled = true
        self.cancelButton.isHidden = true
        self.inputToolbar.isHidden = true
    }
    
    func stopDrwing() {
        endEditing(true)
        self.drawView.isUserInteractionEnabled = false
        self.tempImageView.isUserInteractionEnabled = false
        self.cancelButton.isHidden = false
        self.inputToolbar.isHidden = false
    }
    
    func eraser() {
        drawView.setColor(nil)
    }
    
    func undo() {
        drawView.undo()
    }
    
    func redo() {
        drawView.redo()
    }
    
    func drwingColor(color: UIColor) {
        self.drawView.setColor(color)
        self.drawViewColor = color
        if activeTextView != nil {
            activeTextView?.textColor = color
        }
    }
    
    
    // MARK: - TouchDrawViewDelegate
    func undoEnabled() {
        self.toolsView.undoButton.isEnabled = true
    }

    func undoDisabled() {
        self.toolsView.undoButton.isEnabled = false
    }

    func redoEnabled() {
        self.toolsView.redoButton.isEnabled = true
    }

    func redoDisabled() {
        self.toolsView.redoButton.isEnabled = false
    }

}

extension ImageEditorUI: GrowingTextViewDelegate, UITextViewDelegate {
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(ImageEditorUI.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(ImageEditorUI.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(ImageEditorUI.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageEditorUI.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.layoutIfNeeded()
            }, completion: { (completed) in
        })
    }
}

extension ImageEditorUI {
    public func textViewDidChange(_ textView: UITextView) {
        if textView.tag != 101 {
            
            isCaption = false
            let rotation = atan2(textView.transform.b, textView.transform.a)
            if rotation == 0 {
                let oldFrame = textView.frame
                let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
                textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
            }
        } else {
            isCaption = true
        }

    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.tag != 101 {
            self.toolsView.showTextToolsUI()
            self.cancelButton.isHidden = true
            self.inputToolbar.isHidden = true
            isCaption = false
            lastTextViewTransform =  textView.transform
            lastTextViewTransCenter = textView.center
            lastTextViewFont = textView.font!
            activeTextView = textView
            textView.superview?.bringSubviewToFront(textView)
            textView.font = UIFont(name: "Helvetica", size: 40)
            UIView.animate(withDuration: 0.3,
                           animations: {
                            textView.transform = CGAffineTransform.identity
                            textView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
            }, completion: nil)
            
        } else {
            isCaption = true
        }

    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag != 101 {
            isCaption = false
            guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
                else {
                    return
            }
            activeTextView = nil
            textView.font = self.lastTextViewFont!
            UIView.animate(withDuration: 0.3,
                           animations: {
                            textView.transform = self.lastTextViewTransform!
                            textView.center(inView: self.tempImageView)
            }, completion: nil)
        } else {
            isCaption = true
        }

    }
    
}


// MARK:
extension ImageEditorUI: StickerEmojiDelegate {
    func didRemovedSheet() {
         self.toolsView.setBackStickerToolsUI()
         UIView.animate(withDuration: 0.3) {
           self.cancelButton.isHidden = false
           self.inputToolbar.isHidden = false
        }
    }
    
    func GitTapped(GifName: String) {
        print("Git")
    }
    
    func EmojiTapped(EmojiName: String) {
        self.removeBottomSheetView()
        var emojiView = UIView()
        let emojiLabel = UILabel()
        emojiLabel.text = EmojiName
        emojiLabel.font = UIFont.systemFont(ofSize: 120)
        emojiView = emojiLabel
        self.tempImageView.addSubview(emojiView)
        emojiLabel.center(inView: tempImageView)
        emojiLabel.setDimensions(width: 150, height: 150)
        addGestures(view: emojiView)
        print(emojiLabel.frame)
    }
    
    func StickerTapped(StickerName: String) {
        self.removeBottomSheetView()
        let imageView = UIImageView(image: UIImage(named: StickerName))
        imageView.contentMode = .scaleAspectFit

        self.tempImageView.addSubview(imageView)
        imageView.center(inView: tempImageView)
        imageView.setDimensions(width: 150, height: 150)
        //Gestures
        addGestures(view: imageView)
    }
    
    func addBottomSheetView() {
        for recognizer in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(recognizer)
        }
        
        
         bottomSheetIsVisible = true
         cancelButton.isHidden = true
         inputToolbar.isHidden = true
         self.tempImageView.isUserInteractionEnabled = false
         StickerVC.stickerDelegate = self
         StickerVC.showGif(show: false)
         
        // append stickers
        for stickersImage in self.stickers {
                StickerVC.stickers.append(stickersImage)
            }
         
        
        self.presentationController!.addChild(StickerVC)
        self.addSubview(StickerVC.view)
        StickerVC.didMove(toParent: presentationController)
        let height = self.frame.height
        let width  = self.frame.width
        StickerVC.view.frame = CGRect(x: 0, y: self.frame.maxY , width: width, height: height)
     }
     
     func removeBottomSheetView() {
         cancelButton.isHidden = false
         inputToolbar.isHidden = false
         bottomSheetIsVisible = false
         self.tempImageView.isUserInteractionEnabled = true
         UIView.animate(withDuration: 0.3,
                        delay: 0,
                        options: UIView.AnimationOptions.curveEaseIn,
                        animations: { () -> Void in
                         var frame = self.StickerVC.view.frame
                         frame.origin.y = UIScreen.main.bounds.maxY
                         self.StickerVC.view.frame = frame
                         
         }, completion: { (finished) -> Void in
             self.StickerVC.view.removeFromSuperview()
             self.StickerVC.removeFromParent()
             self.toolsView.setBackStickerToolsUI()
             UIView.animate(withDuration: 0.3) {
                self.cancelButton.isHidden = false
                self.inputToolbar.isHidden = false
             }

            
         })
     }

}
