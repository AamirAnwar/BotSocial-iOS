//
//  BSUserSnippetTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit
import PINRemoteImage

class BSUserSnippetTableViewCell: UITableViewCell {
    
    let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    let usernameLabel:UILabel = {
        let label = UILabel()
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.userImageView)
        self.contentView.addSubview(self.usernameLabel)
        
        self.userImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.userImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            make.height.equalTo(kUserThumbnailImageHeight)
            make.width.equalTo(kUserThumbnailImageHeight)
        }
//        self.userImageView.pin_setImage(from: URL(string:kTestImageURL)!)
        self.userImageView.layer.cornerRadius =  round(kUserThumbnailImageHeight/2)
        self.usernameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.userImageView.snp.centerY)
            make.trailing.lessThanOrEqualToSuperview().inset(kSidePadding)
            make.leading.equalTo(self.userImageView.snp.trailing).offset(kInteritemPadding)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.greaterThanOrEqualToSuperview()
        }
        
    }
    
    func setImageURL(_ url:URL?) {
        self.userImageView.pin_setImage(from:url)
    }
    
    

}
