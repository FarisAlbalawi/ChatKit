//
//  ToolsView.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/23/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit


protocol ToolsDelegate {
    func startDrwing()
    func stopDrwing()
    func eraser()
    func undo()
    func redo()
    func drwingColor(color: UIColor)
    func startCropping()
    func doneCropping()
    func textTapped()
    func stopText()
    func showStickers()
    func hideStickers()
    
}



class ToolsView: UIView {

    var DTDelegate: ToolsDelegate?
    
    
    let textButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let icon = UIImage(named: "text_1")
        button.setImage(icon, for: .normal)
        button.setImage(UIImage(named: "text_2"), for: UIControl.State.selected)
        button.setImage(UIImage(named: "text_2"), for: UIControl.State.highlighted)
        button.setImage(UIImage(named: "text_2"), for: UIControl.State.focused)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let penButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let icon = UIImage(named: "pen_1")
        button.setImage(UIImage(named:"pen_2"), for: UIControl.State.selected)
        button.setImage(UIImage(named: "pen_2"), for: UIControl.State.highlighted)
        button.setImage(UIImage(named: "pen_2"), for: UIControl.State.focused)
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    
    
    let stickerButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let icon = UIImage(named: "sticker_1")
        button.setImage(UIImage(named: "sticker_2"), for: UIControl.State.selected)
        button.setImage(UIImage(named: "sticker_2"), for: UIControl.State.highlighted)
        button.setImage(UIImage(named: "sticker_2"), for: UIControl.State.focused)
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let cropButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let icon = UIImage(named: "crop_1")
        button.setImage(UIImage(named: "crop_2"), for: UIControl.State.selected)
        button.setImage(UIImage(named: "crop_2"), for: UIControl.State.highlighted)
        button.setImage(UIImage(named: "crop_2"), for: UIControl.State.focused)
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    
    private var buttonStackView: UIStackView = {
         let stackView = UIStackView()
         stackView.backgroundColor = .clear
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.axis = .horizontal
         stackView.alignment = .center
         stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
         stackView.semanticContentAttribute = .forceRightToLeft
         return stackView
     }()
    
    
    let colorSlider: ColorSlider = {
     
        let colorSlider = ColorSlider(orientation: .horizontal, previewSide: .bottom)
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    
        
        colorSlider.gradientView.layer.borderWidth = 2.0
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        return colorSlider
        
    }()
    
    
    
    let undoButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.backgroundColor = .clear
        let icon = UIImage(named: "undo")
        button.setImage(icon, for: .normal)
        
        return button
    }()
    
    
    
    let redoButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.backgroundColor = .clear
        let icon = UIImage(named: "redo")
        button.setImage(icon, for: .normal)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.addSubview(buttonStackView)
        self.buttonStackView.addArrangedSubview(textButton)
        self.buttonStackView.setCustomSpacing(22, after: textButton)
        self.buttonStackView.addArrangedSubview(penButton)
        self.buttonStackView.setCustomSpacing(22, after: penButton)
        self.buttonStackView.addArrangedSubview(stickerButton)
        self.buttonStackView.setCustomSpacing(22, after: stickerButton)
        self.buttonStackView.addArrangedSubview(cropButton)
        

        textButton.addTarget(self, action:#selector(didPressText(_:)), for: UIControl.Event.touchUpInside)
        penButton.addTarget(self, action:#selector(didPressPen(_:)), for: UIControl.Event.touchUpInside)
        stickerButton.addTarget(self, action:#selector(didPressSticker(_:)), for: UIControl.Event.touchUpInside)
        cropButton.addTarget(self, action:#selector(didPressCrop(_:)), for: UIControl.Event.touchUpInside)
        
    
    
        self.buttonStackView.addArrangedSubview(colorSlider)
        self.buttonStackView.addArrangedSubview(undoButton)
        self.buttonStackView.addArrangedSubview(redoButton)
        self.colorSlider.isHidden = true
        self.undoButton.isHidden = true
        self.redoButton.isHidden = true
   
      
        undoButton.addTarget(self, action:#selector(undoClicked(_:)), for: UIControl.Event.touchUpInside)
        redoButton.addTarget(self, action:#selector(redoClicked(_:)), for: UIControl.Event.touchUpInside)
        
        
        textButton.setDimensions(width: 35, height: 35)
        penButton.setDimensions(width: 35, height: 35)
        stickerButton.setDimensions(width: 35, height: 35)
        cropButton.setDimensions(width: 35, height: 35)
        colorSlider.setDimensions(width: 200, height: 20)
        undoButton.setDimensions(width: 35, height: 35)
        redoButton.setDimensions(width: 35, height: 35)

        buttonStackView.anchor(right: rightAnchor)

       
        
    }
    

    @objc func didPressText(_ sender: UIButton) {
         colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
        if sender.tag == 0 {
            DTDelegate?.textTapped()
            sender.tag = 1
            sender.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let icon = UIImage(named: "text_2")
            sender.setImage(icon, for: .normal)
            self.penButton.isHidden = true
            self.stickerButton.isHidden = true
            self.cropButton.isHidden = true
     
            self.buttonStackView.setCustomSpacing(20, after: textButton)
            self.colorSlider.isHidden = false
        } else {
            DTDelegate?.stopText()
            sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            let icon = UIImage(named: "text_1")
            sender.setImage(icon, for: .normal)
            sender.tag = 0
            sender.backgroundColor = .clear
            self.penButton.isHidden = false
            self.stickerButton.isHidden = false
            self.cropButton.isHidden = false
            
            self.colorSlider.isHidden = true
            
            self.buttonStackView.setCustomSpacing(22, after: textButton)
            
        }

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
    }
    
    
    @objc func didPressPen(_ sender: UIButton) {
        if sender.tag == 0 {
            DTDelegate?.startDrwing()
            sender.tag = 1
            sender.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let icon = UIImage(named: "pen_2")
            sender.setImage(icon, for: .normal)
            self.textButton.isHidden = true
            self.stickerButton.isHidden = true
            self.cropButton.isHidden = true

            self.colorSlider.isHidden = false
          
            self.undoButton.isHidden = false
            self.redoButton.isHidden = false
            
            self.buttonStackView.setCustomSpacing(20, after: self.penButton)
            self.buttonStackView.setCustomSpacing(20, after: self.colorSlider)
            self.buttonStackView.setCustomSpacing(10, after: self.undoButton)
            
        } else {
            DTDelegate?.stopDrwing()
            sender.tag = 0
            sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            let icon = UIImage(named: "pen_1")
            sender.setImage(icon, for: .normal)
            sender.backgroundColor = .clear
            self.textButton.isHidden = false
            self.stickerButton.isHidden = false
            self.cropButton.isHidden = false
            
            self.colorSlider.isHidden = true
    
            self.undoButton.isHidden = true
            self.redoButton.isHidden = true
            self.buttonStackView.setCustomSpacing(22, after: self.penButton)
            
        }

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    
    @objc func didPressSticker(_ sender: UIButton) {
        if sender.tag == 0 {
            self.DTDelegate?.showStickers()
            sender.tag = 1
            sender.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let icon = UIImage(named: "sticker_2")
            sender.setImage(icon, for: .normal)
            self.textButton.isHidden = true
            self.penButton.isHidden = true
            self.cropButton.isHidden = true
     
        } else {
            self.DTDelegate?.hideStickers()
            sender.tag = 0
            sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            let icon = UIImage(named: "sticker_1")
            sender.setImage(icon, for: .normal)
            sender.backgroundColor = .clear
            self.textButton.isHidden = false
            self.penButton.isHidden = false
            self.cropButton.isHidden = false
    
            
        }

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func didPressCrop(_ sender: UIButton) {
        if sender.tag == 0 {
            DTDelegate?.startCropping()
            sender.tag = 1
            sender.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let icon = UIImage(named: "crop_2")
            sender.setImage(icon, for: .normal)
            self.textButton.isHidden = true
            self.penButton.isHidden = true
            self.stickerButton.isHidden = true
     
        } else {
            sender.tag = 0
            DTDelegate?.doneCropping()
            sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            let icon = UIImage(named: "crop_1")
            sender.setImage(icon, for: .normal)
            sender.backgroundColor = .clear
            self.textButton.isHidden = false
            self.penButton.isHidden = false
            self.stickerButton.isHidden = false
    
            
        }

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    

    
    @objc func undoClicked(_ sender: UIButton) {
      DTDelegate?.undo()
    }

    @objc func redoClicked(_ sender: UIButton) {
        DTDelegate?.redo()
    }
    
    
     
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        DTDelegate?.drwingColor(color: color)
    
     }
    
    func showTextToolsUI() {
        textButton.tag = 1
        textButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let icon = UIImage(named: "text_2")
        textButton.setImage(icon, for: .normal)
        self.penButton.isHidden = true
        self.stickerButton.isHidden = true
        self.cropButton.isHidden = true
    
        self.buttonStackView.setCustomSpacing(20, after: textButton)
        self.colorSlider.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func setBackTextToolsUI() {
        DTDelegate?.stopText()
        textButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let icon = UIImage(named: "text_1")
        textButton.setImage(icon, for: .normal)
        textButton.tag = 0
        textButton.backgroundColor = .clear
        self.penButton.isHidden = false
        self.stickerButton.isHidden = false
        self.cropButton.isHidden = false
        
        self.colorSlider.isHidden = true
        
        self.buttonStackView.setCustomSpacing(22, after: textButton)
        

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
    }
    
    func setBackStickerToolsUI() {
        stickerButton.tag = 0
        stickerButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let icon = UIImage(named: "sticker_1")
        stickerButton.setImage(icon, for: .normal)
        stickerButton.backgroundColor = .clear
        self.textButton.isHidden = false
        self.penButton.isHidden = false
        self.cropButton.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }

    }
    
}
