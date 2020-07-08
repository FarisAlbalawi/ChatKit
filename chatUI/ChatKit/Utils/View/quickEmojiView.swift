//
//  quickEmojiView.swift
//  chatUI
//
//  Created by Faris Albalawi on 5/31/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit

protocol quickEmojiDelegate {
    func EmojiTapped(index: Int)
}
class quickEmojiView: UIView {
    
    var delegate: quickEmojiDelegate?
    
    let quickEmojiArray = ["emoji_1","emoji_2","emoji_3","emoji_4","emoji_5","emoji_6","emoji_7","emoji_8"]
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    func setupUIElements() {
        let width = (UIScreen.main.bounds.width / 8) - 15
        print(width)
        self.addSubview(mainView)
        mainView.anchor(top:topAnchor,left: leftAnchor,bottom: bottomAnchor,right: rightAnchor,paddingLeft: 10,paddingRight: 20,height: width+20)
        
        self.mainView.addSubview(stackView)
        stackView.anchor(height: width+20)
        mainView.frame = frame
        for i in 0..<quickEmojiArray.count {
            let img = UIImageView()
            img.tag = i
            img.contentMode = .scaleAspectFit
            img.image = UIImage(named: "\(quickEmojiArray[i])")
            img.setDimensions(width: width, height: width)
            
            stackView.addArrangedSubview(img)
            stackView.spacing = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(quickEmojiView.tappedImage))
            img.addGestureRecognizer(tap)
            img.isUserInteractionEnabled = true
        }
    
    }
    
    
    @objc func tappedImage(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        delegate?.EmojiTapped(index: tag)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
