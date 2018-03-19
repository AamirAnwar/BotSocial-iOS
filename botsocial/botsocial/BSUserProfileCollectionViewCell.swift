//
//  BSUserProfileTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSUserProfileCollectionViewCell: UICollectionViewCell {
    let userThumbnailImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints({ (make) in
            make.size.equalTo(88)
        })
        imageView.layer.cornerRadius = 44
        imageView.pin_setImage(from: URL(string:kTestImageURL)!)
        return imageView
    }()
    
    let usernameLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createViews()
    }
    func createViews() {
        self.contentView.addSubview(self.userThumbnailImageView)
        self.contentView.addSubview(self.usernameLabel)
        self.userThumbnailImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.greaterThanOrEqualToSuperview().offset(kInteritemPadding)
            
        }
        self.usernameLabel.text = "Aamir Anwar"
        self.usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userThumbnailImageView.snp.leading)
            make.top.equalTo(self.userThumbnailImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            
        }
    }
}
