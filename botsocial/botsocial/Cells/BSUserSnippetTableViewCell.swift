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

protocol BSUserSnippetTableViewCellDelegate {
    func moreButtonTapped(sender:UITableViewCell)
}

class BSUserSnippetTableViewCell: UITableViewCell {
    var delegate:BSUserSnippetTableViewCellDelegate?
    let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.font = BSFontMediumBold
        label.textColor = BSColorTextBlack
        return label
    }()
    
    let moreButton:UIButton = {
       let button = UIButton.init(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "more_icon"), for: .normal)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.userImageView)
        self.contentView.addSubview(self.usernameLabel)
        self.contentView.addSubview(self.moreButton)
        
        self.moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        self.moreButton.isHidden = true
        self.userImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.userImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            make.height.equalTo(kUserThumbnailImageSize)
            make.width.equalTo(kUserThumbnailImageSize)
        }
        self.userImageView.layer.cornerRadius =  round(kUserThumbnailImageSize/2)
        self.usernameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.userImageView.snp.centerY)
            make.trailing.lessThanOrEqualTo(self.moreButton).inset(kSidePadding)
            make.leading.equalTo(self.userImageView.snp.trailing).offset(kInteritemPadding)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.greaterThanOrEqualToSuperview()
        }
        
        self.moreButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.usernameLabel)
            make.size.equalTo(13)
        }
        
    }
    
    func configureWith(post:BSPost) {
        usernameLabel.text = post.authorName
        moreButton.isHidden = true
        if let authorID = post.authorID {
            APIService.sharedInstance.getProfilePictureFor(userID: authorID, completion: {(url,handle) in
                self.setImageURL(url)
            })
            if let currentUser = APIService.sharedInstance.currentUser {
                if currentUser.uid == authorID {
                    self.moreButton.isHidden = false
                }
                else {
                    self.moreButton.isHidden = true
                }
            }
        }
        
    }
    
    func setImageURL(_ url:URL?) {
        self.userImageView.image = #imageLiteral(resourceName: "placeholder_image")
        if let url = url {
            self.userImageView.pin_setImage(from:url)
        }
    }
    
    @objc func moreButtonTapped() {
        self.delegate?.moreButtonTapped(sender: self)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = #imageLiteral(resourceName: "placeholder_image")
        
    }
}
