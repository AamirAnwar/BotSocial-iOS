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
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = BSColorTextBlack
        self.titleLabel.font = BSFontMediumParagraph
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userThumbnailImageView.snp.trailing).offset(kInteritemPadding)
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
    
    func configureWith(authorName:String, title:String, imageURL:URL? = nil) {
        let string = NSMutableAttributedString.init(string: "\(authorName)", attributes: [.font:BSFontMediumBold])
        string.append(NSAttributedString.init(string: " \(title)", attributes: [.font:BSFontMediumParagraph]))
        self.titleLabel.attributedText = string
        self.userThumbnailImageView.pin_setImage(from: imageURL)
    }
 
}
