//
//  Configs.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/22/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation
import UIKit



 let screenSize: CGRect = UIScreen.main.bounds

// MARK: DATE FROMAT FOR TIME HH:MM A
func dateFormatTime(date : Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    return dateFormatter.string(from: date)
}

