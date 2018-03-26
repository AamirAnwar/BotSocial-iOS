//
//  BSAddCommentTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSAddCommentTableViewCell: UITableViewCell {
    let textField:UITextField = {
        let textField = UITextField.init()
        textField.placeholder = "Add a comment"
        return textField
    }()
    
    let commentCountLabel:UILabel = {
        let label = UILabel()
        label.text = "View all 1,639 comments"
        return label
    }()
    
    let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.textField)
        self.contentView.addSubview(self.commentCountLabel)
        self.contentView.addSubview(self.userImageView)
        self.selectionStyle = .none
        APIService.sharedInstance.getUserProfileImageURL { (url) in
            if let url = url {
                self.userImageView.pin_setImage(from: url)
            }
        }
        
        self.userImageView.layer.cornerRadius =  20
        self.commentCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.userImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.height.equalTo(self.textField.snp.height)
            make.width.equalTo(self.textField.snp.height)
            make.centerY.equalTo(self.textField.snp.centerY)
        }
        
        self.textField.snp.makeConstraints { (make) in
            make.top.equalTo(self.commentCountLabel.snp.bottom).offset(kInteritemPadding)
            make.leading.equalTo(self.userImageView.snp.trailing).offset(kInteritemPadding)
            make.trailing.equalTo(self.commentCountLabel.snp.trailing)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
    }

}
