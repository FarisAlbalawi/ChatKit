//
//  Messages.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/20/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit


public struct User {
    var userId: String
    var fullname: String
    var avatar: UIImage?
}

enum MessageType: Int, Decodable {
    case text = 0
    case file
    case sticker
    case map
    case audio
    case caption
    
}

enum StickerType: Int, Decodable {
    case emoji = 0
    case sticker
    case git
}




/// Messages Model

public struct Messages {
    
    let user: User
    let objectId: String
    let type: MessageType
    var text: String?
    var latitude: Double?
    var longitude: Double?
    var stickerName: String?
    var stickerType: StickerType?
    var image: UIImage?
    var audio: URL?
    let createdAt: Date!
    var isIncoming: Bool = true
    
//    init(type: MessageType,
//         text: String?,
//         file: String?,
//         stickerName: String?,
//         audio: String?,
//         createdAt: Date!,
//         isIncoming: Bool,
//         latitude: Double?,
//         longitude: Double?
//         ) {
//        self.type = type
//        self.text = text
//        self.file = file
//        self.stickerName = stickerName
//        self.audio = audio
//        self.createdAt = createdAt
//        self.isIncoming = isIncoming
//        self.latitude = latitude
//        self.longitude = longitude
//    }
    
    
    init(objectId: String,user: User, type: MessageType, createdAt: Date, isIncoming: Bool) {
        self.objectId = objectId
        self.user = user
        self.type = type
        self.createdAt = createdAt
        self.isIncoming = isIncoming
    }

    
    /// Initialize text message
    init(objectId: String,user: User,text: String, createdAt: Date, isIncoming: Bool) {
        self.init(objectId: objectId,user: user ,type: .text, createdAt: createdAt, isIncoming: isIncoming)
        self.text = text
    }
    
    
    /// Initialize file message
    init(objectId: String,user: User,image: UIImage, createdAt: Date, isIncoming: Bool) {
        self.init(objectId: objectId,user: user ,type: .file, createdAt: createdAt, isIncoming: isIncoming)
        self.image = image
    }
    
    /// Initialize caption message
    init(objectId: String,user: User,image: UIImage,text: String?, createdAt: Date, isIncoming: Bool) {
        self.init(objectId: objectId,user: user ,type: .caption, createdAt: createdAt, isIncoming: isIncoming)
        self.image = image
        self.text = text
    }
    
    

    /// Initialize emoji message
    init(objectId: String,user: User,stickerName: String, StickerType: StickerType, createdAt: Date, isIncoming: Bool) {
        self.init(objectId: objectId,user: user ,type: .sticker, createdAt: createdAt, isIncoming: isIncoming)
        self.stickerType = StickerType
        self.stickerName = stickerName
    }
    
    
    /// Initialize map message
    init(objectId: String,user: User,latitude: Double, longitude: Double, createdAt: Date, isIncoming: Bool) {
        self.init(objectId: objectId,user: user ,type: .caption, createdAt: createdAt, isIncoming: isIncoming)
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    /// Initialize audio message
    init(objectId: String,user: User,audio: URL, createdAt: Date, isIncoming: Bool) {
        self.init(objectId: objectId,user: user ,type: .audio, createdAt: createdAt, isIncoming: isIncoming)
        self.audio = audio
    }
    
    
    func cellIdentifer() -> String {
        switch type {
        case .text:
            return MessageTextCell.reuseIdentifier
        case .file:
            return MessageImageCell.reuseIdentifier
        case .sticker:
            return MessageEmojiCell.reuseIdentifier
        case .map:
            return MessageMapCell.reuseIdentifier
        case .audio:
            return MessageAudioCell.reuseIdentifier
        case .caption:
            return MessageCaptionCell.reuseIdentifier
        }
    }
}
