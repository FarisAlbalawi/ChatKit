//
//  MessagesTableViews.swift
//  chatUI
//
//  Created by Faris Albalawi on 7/14/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class MessagesTableViews: UITableView {

    private var indexPathForLastItem: IndexPath? {
        let lastSection = numberOfSections - 1
        guard lastSection >= 0, numberOfRows(inSection: lastSection) > 0 else { return nil }
        return IndexPath(item: numberOfRows(inSection: lastSection) - 1, section: lastSection)
    }

    /// Registers a particular cell using its reuse-identifier
    public func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: T.self))
    }

    
    // MARK: - Initializers
    
    override init(frame: CGRect, style: UITableView.Style) {
         super.init(frame: frame, style: style)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

      public convenience init() {
          self.init(frame: .zero)
      }
    
    
    // MARK: - Methods
     
     private func registerReusableViews() {
         register(MessageTextCell.self)
         register(MessageImageCell.self)
         register(MessageCaptionCell.self)
         register(MessageEmojiCell.self)
         register(MessageAudioCell.self)
        
     }
    
    // NOTE: It's possible for small content size this wouldn't work - https://github.com/MessageKit/MessageKit/issues/725
    public func scrollToLastItem(at pos: UITableView.ScrollPosition = .bottom, animated: Bool = true) {
        guard numberOfSections > 0 else { return }
        
        let lastSection = numberOfSections - 1
        let lastItemIndex = numberOfRows(inSection: lastSection) - 1
        
        guard lastItemIndex >= 0 else { return }
        
        let indexPath = IndexPath(row: lastItemIndex, section: lastSection)
        scrollToRow(at: indexPath, at: pos, animated: animated)
    }
    
    public func reloadDataAndKeepOffset() {
        // stop scrolling
        setContentOffset(contentOffset, animated: false)
        
        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Unable to dequeue \(String(describing: cellClass)) with reuseId of \(String(describing: T.self))")
        }
        return cell
    }
}
