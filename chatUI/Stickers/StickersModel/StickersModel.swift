//
//  StickersModel.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/16/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit

struct stickerPacks {
    var packnames: String?
    var iconName: String?
    var iconURL: URL?
    var stickers: [stickers]?
    init(){}
}

struct stickers {
    var imageURL: URL?
    var imageName: String?
    var name: String?
}
