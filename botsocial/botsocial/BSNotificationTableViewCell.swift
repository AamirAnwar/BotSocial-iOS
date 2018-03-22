//
//  BSNotificationTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSNotificationTableViewCell: UITableViewCell {
    let userThumbnailImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints({ (make) in
            make.size.equalTo(44)
        })
        imageView.layer.cornerRadius = 22
//        imageView.pin_setImage(from: URL(string:kTestImageURL)!)
        return imageView
    }()
    
    let titleLabel = UILabel()
    let containerView = UIView()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.containerView.addSubview(self.userThumbnailImageView)
        self.contentView.addSubview(self.containerView)
        
        self.userThumbnailImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.greaterThanOrEqualToSuperview().offset(kInteritemPadding)
        }
        
        self.containerView.addSubview(self.titleLabel)
        if arc4random() % 2 == 0 {
            self.titleLabel.text = "aamiranwarr liked your post. 40m"
        }
        else {
            self.titleLabel.text = "aamiranwarr commented on your post \" This has got to be the best app ever made\" 40m"
        }
        self.titleLabel.numberOfLines = 0
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userThumbnailImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.userThumbnailImageView.snp.centerY)
            make.top.equalToSuperview().offset(kInteritemPadding).priority(100)
            
        }
        NSLayoutConstraint.activate([
            self.contentView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0),
            ])
        self.containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.containerView.snp.makeConstraints { (make) in
            make.bottom.greaterThanOrEqualTo(self.userThumbnailImageView.snp.bottom).offset(kInteritemPadding).priority(1000)
            make.bottom.equalTo(self.titleLabel.snp.bottom).offset(kInteritemPadding).priority(100)

        }
    }
    
    func configureWith(title:String, imageURL:URL? = nil) {
        self.titleLabel.text = title
        self.userThumbnailImageView.pin_setImage(from: imageURL)
    }
 
}
