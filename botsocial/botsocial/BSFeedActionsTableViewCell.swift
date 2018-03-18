//
//  BSFeedActionsTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSFeedActionsTableViewCell: UITableViewCell {
    
    static var standardButton:UIButton {
        get {
            let button = UIButton.init(type: .system)
            button.layer.cornerRadius = kCornerRadius
            button.setTitleColor(UIColor.black, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 4)
            return button
        }
    }
    
    let likeButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("36 Likes", for: .normal)
        return button
    }()
    
    let dislikeButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("49 Dislikes", for: .normal)
        return button
    }()
    
    let commentButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("1,709 Comments", for: .normal)
        return button
    }()
    
    let saveButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("Save", for: .normal)
        return button
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.likeButton)
        self.contentView.addSubview(self.dislikeButton)
        self.contentView.addSubview(self.commentButton)
        self.contentView.addSubview(self.saveButton)
        
        self.selectionStyle = .none
        self.likeButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
        
        self.dislikeButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.likeButton.snp.trailing).offset(kInteritemPadding)
            make.centerY.equalTo(self.likeButton.snp.centerY)
        }
        
        self.commentButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.dislikeButton.snp.trailing).offset(kInteritemPadding)
            make.centerY.equalTo(self.dislikeButton.snp.centerY)
        }
        
        self.saveButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.dislikeButton.snp.centerY)
            make.leading.greaterThanOrEqualTo(self.commentButton.snp.trailing)
        }
    }
}
