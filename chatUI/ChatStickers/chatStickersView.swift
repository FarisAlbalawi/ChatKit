//
//  chatStickersView.swift
//  chatUI
//
//  Created by Faris Albalawi on 7/7/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit


@objc protocol stickersGifDelegate {
    @objc optional func sendSticker(name: String)
    @objc optional func SendGif(name: String)
}

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
    
    required public init?(coder: NSCoder) {
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

class chatStickersView: chatStickersUI {
    
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
    
    weak var stickersCollectionView: UICollectionView!
    weak var gifsCollectionView: UICollectionView!

    // data
        
    public var stickers : [String] = []
    public var gifs : [String] = []
    
    weak var stickerGifDelegate: stickersGifDelegate?
    
     override func setupUIElements() {
        
        for i in 100...110 {
            stickers.append(i.description)
        }
        
        
        let gifImage = ["gif1","gif2","gif3","gif4", "gif5","gif6","gif7","gif8", "gif9","gif10","gif11","gif12"]
        
        for i in gifImage {
            gifs.append(i)
        }
        
        let stickerGesture = UITapGestureRecognizer(target: self, action:  #selector(self.didPressSticker))
        stickerView.addGestureRecognizer(stickerGesture)
        
        
        let gifGesture = UITapGestureRecognizer(target: self, action:  #selector(self.didPressGif))
        gifView.addGestureRecognizer(gifGesture)
        
         self.layer.cornerRadius = 10
         self.addSubview(iconstackView)
         self.iconstackView.addArrangedSubview(stickerView)
         self.iconstackView.addArrangedSubview(gifView)
        
         /// stickers
         let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
         self.addSubview(collectionView)
         self.stickersCollectionView = collectionView
          
        /// gifs
         let gifcollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
         self.addSubview(gifcollectionView)
         self.gifsCollectionView = gifcollectionView
        
        
        
          // set dataSource and delegate
          self.stickersCollectionView.dataSource = self
          self.stickersCollectionView.delegate = self
          
         self.gifsCollectionView.dataSource = self
         self.gifsCollectionView.delegate = self
        
          
          // register cell
          self.stickersCollectionView.register(stickerGifCell.self, forCellWithReuseIdentifier: "cell")
          self.gifsCollectionView.register(stickerGifCell.self, forCellWithReuseIdentifier: "cell")
          
        
          self.stickersCollectionView.alwaysBounceVertical = true
          self.stickersCollectionView.backgroundColor = .clear
          self.stickersCollectionView.alwaysBounceVertical = true
          self.gifsCollectionView.backgroundColor = .clear
        
         self.gifsCollectionView.isHidden = true
        
     }
     
     override func setupConstraints() {
        self.stickersCollectionView.anchor(top: topAnchor,left: leftAnchor,right: rightAnchor,height: 260)
         self.gifsCollectionView.anchor(top: topAnchor,left: leftAnchor,right: rightAnchor, height: 260)
         self.iconstackView.centerX(inView: self)
         self.iconstackView.anchor(bottom: bottomAnchor)
         
     }
     
     
     
     @objc private func didPressGif() {
         self.gifsCollectionView.isHidden = false
         self.stickersCollectionView.isHidden = true
         let generator = UIImpactFeedbackGenerator(style: .heavy)
         generator.impactOccurred()
         self.gifView.backgroundColor = .systemGray4
         self.stickerView.backgroundColor = .clear
         self.gifView.icon.tintColor = .white
         self.stickerView.icon.tintColor = .systemGray2
    
         
     }
     
     @objc private func didPressSticker() {
         self.gifsCollectionView.isHidden = true
         self.stickersCollectionView.isHidden = false
         let generator = UIImpactFeedbackGenerator(style: .heavy)
         generator.impactOccurred()
         self.stickerView.backgroundColor = .systemGray4
         self.gifView.backgroundColor = .clear
         self.gifView.icon.tintColor = .systemGray2
         self.stickerView.icon.tintColor = .white
     }
     
}

extension chatStickersView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        if collectionView == stickersCollectionView {
            return self.stickers.count
        } else {
             return self.gifs.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "cell"
        if collectionView == stickersCollectionView {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! stickerGifCell
            cell.stickerImage.image = UIImage(named: stickers[indexPath.row])
            
            
            
            return cell
        } else {
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! stickerGifCell
            let gif =  UIImage.gif(name: gifs[indexPath.row])
            cell.stickerImage.image = gif
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == stickersCollectionView {
            self.stickerGifDelegate?.sendSticker?(name: stickers[indexPath.row])
        } else {
             self.stickerGifDelegate?.SendGif?(name: gifs[indexPath.row])
        }
    }
}


extension chatStickersView: UICollectionViewDelegateFlowLayout {

    
    // set cell size
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/4, height: collectionView.bounds.width/4)
    }

    // set cell size
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    // set cell inter-item spacing
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    // set cell Line spacing
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

