//
//  chatStickersUI.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/16/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit


class switchIconView: UIView {
    
   lazy var icon: UIImageView = {
        let icons = UIImageView()
        icons.contentMode = .scaleAspectFit
        icons.tintColor = UIColor.systemGray3
        return icons
         
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(icon: UIImage) {
        self.init(frame: .zero)
        self.icon.image = icon.withRenderingMode(.alwaysTemplate)
    }
    
    
   private func setupUIElements() {
        self.addSubview(icon)
        self.icon.center(inView: self)
        self.icon.setDimensions(width: 25, height: 25)
    }



    
    
}

class chatStickersUI: UIView {
    
    
    private var gifView: switchIconView = {
        let view = switchIconView(icon: UIImage(named: "gif_icon")!)
        view.layer.cornerRadius = 35/2
        view.setDimensions(width: UIScreen.main.bounds.width / 2 - 20, height: 35)
        view.icon.tintColor = .systemGray2
        return view
    }()
    
    private var stickerView: switchIconView = {
        let view = switchIconView(icon: UIImage(named: "sticker_icon2")!)
        view.layer.cornerRadius = 35/2
        view.backgroundColor = .systemGray4
        view.setDimensions(width: UIScreen.main.bounds.width / 2 - 20, height: 35)
        view.icon.tintColor = .white
        return view
    }()
    
    private var iconstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stickerGesture = UITapGestureRecognizer(target: self, action:  #selector(self.didPressSticker))
        stickerView.addGestureRecognizer(stickerGesture)
        
        
        let gifGesture = UITapGestureRecognizer(target: self, action:  #selector(self.didPressGif))
        gifView.addGestureRecognizer(gifGesture)
        
        self.setupUIElements()
        self.setupConstraints()
    }
    
    
    private func setupUIElements() {
        self.layer.cornerRadius = 10
        self.addSubview(iconstackView)
        self.iconstackView.addArrangedSubview(stickerView)
        self.iconstackView.addArrangedSubview(gifView)
    }
    
    private func setupConstraints() {
        self.iconstackView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 5)
        
    }
    
    
    
    @objc private func didPressGif() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        self.gifView.backgroundColor = .systemGray4
        self.stickerView.backgroundColor = .clear
        self.gifView.icon.tintColor = .white
        self.stickerView.icon.tintColor = .systemGray2
   
        
    }
    
    @objc private func didPressSticker() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        self.stickerView.backgroundColor = .systemGray4
        self.gifView.backgroundColor = .clear
        self.gifView.icon.tintColor = .systemGray2
        self.stickerView.icon.tintColor = .white
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
