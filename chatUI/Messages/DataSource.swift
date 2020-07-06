//
//  DataSource.swift
//  chatUI
//
//  Created by Faris Albalawi on 6/8/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import Foundation

/// Used to provide messages to the `TableView`
public protocol DataSource: NSObjectProtocol {

    func numberOfSections() -> Int
    func numberOfMessages(in section: Int) -> Int
    func message(for indexPath: IndexPath) -> Messages
    func headerTitle(for section: Int) -> [Messages]
    
}
