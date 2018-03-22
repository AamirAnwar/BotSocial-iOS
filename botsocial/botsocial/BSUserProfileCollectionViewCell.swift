//
//  BSUserProfileTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import Firebase
protocol BSUserProfileCollectionViewCellDelegate {
    func didTapUserProfileThumb()
    func didTapSettingsButton()
}

class BSUserProfileCollectionViewCell: UICollectionViewCell {
    var delegate:BSUserProfileCollectionViewCellDelegate?
    let settingsButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "settings_icon"), for: .normal)
        button.tintColor = UIColor.black
        return button
    }()
    let userThumbnailImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        imageView.snp.makeConstraints({ (make) in
            make.size.equalTo(88)
        })
        imageView.layer.cornerRadius = 44
        APIService.sharedInstance.getUserProfileImageURL(completion: { (url) in
            if let url = url {
                imageView.pin_setImage(from: url)
            }
        })
        
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
        self.contentView.addSubview(self.settingsButton)
        self.settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        self.settingsButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalTo(self.userThumbnailImageView.snp.top)
            make.size.equalTo(22)
        }
        
        self.userThumbnailImageView.isUserInteractionEnabled = true
        self.userThumbnailImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapThumb)))
        self.userThumbnailImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.greaterThanOrEqualToSuperview().offset(kInteritemPadding)
            
        }
        self.usernameLabel.text = Auth.auth().currentUser?.displayName
        self.usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userThumbnailImageView.snp.leading)
            make.top.equalTo(self.userThumbnailImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            
        }
    }
    
    @objc func didTapThumb() {
        self.delegate?.didTapUserProfileThumb()
    }
    @objc func didTapSettingsButton() {
        self.delegate?.didTapSettingsButton()
    }
}
