//
//  BSUserProfileTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import Firebase

let kProfilePictureSize:CGFloat = 88
protocol BSUserProfileCollectionViewCellDelegate {
    func didTapUserProfileThumb()
    func didTapSettingsButton()
}

class BSUserProfileCollectionViewCell: UICollectionViewCell {
    var delegate:BSUserProfileCollectionViewCellDelegate?
    let settingsButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "settings_icon"), for: .normal)
        button.tintColor = BSColorTextBlack
        return button
    }()
    let userThumbnailImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        imageView.snp.makeConstraints({ (make) in
            make.size.equalTo(kProfilePictureSize)
        })
        imageView.layer.cornerRadius = 44
        return imageView
    }()
    
    let changePictureImageView = UIImageView.init(image: #imageLiteral(resourceName: "camera_tab_icon"))
    
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
        self.contentView.addSubview(self.changePictureImageView)
        self.settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        self.settingsButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalTo(self.userThumbnailImageView.snp.top)
            make.size.equalTo(22)
        }
        
        let size:CGFloat = 15
        
        self.changePictureImageView.clipsToBounds = true
        self.changePictureImageView.isUserInteractionEnabled = true
        self.changePictureImageView.contentMode = .scaleAspectFill
        self.changePictureImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapThumb)))
        self.changePictureImageView.alpha = 0.8
        self.changePictureImageView.layer.cornerRadius = size/2
        self.changePictureImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.userThumbnailImageView.snp.centerX).offset(kProfilePictureSize/4)
            make.centerY.equalTo(self.userThumbnailImageView.snp.centerY).offset(kProfilePictureSize/4)
            make.size.equalTo(15)
        }
        
        self.userThumbnailImageView.isUserInteractionEnabled = true
        self.userThumbnailImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapThumb)))
        self.userThumbnailImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.greaterThanOrEqualToSuperview().offset(kInteritemPadding)
            
        }
        self.usernameLabel.textColor = BSColorTextBlack
        self.usernameLabel.font = BSFontMediumBold
        self.usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.userThumbnailImageView.snp.leading)
            make.top.equalTo(self.userThumbnailImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            
        }
    }
    
    func configureWithUser(user:BSUser? = nil) {
        if let user = user {
            self.usernameLabel.text = user.displayName
            APIService.sharedInstance.getProfilePictureFor(userID: user.id, completion: { (url) in
                self.userThumbnailImageView.pin_setImage(from: url)
            })
        }
        else {
            self.usernameLabel.text = Auth.auth().currentUser?.displayName
            APIService.sharedInstance.getUserProfileImageURL(completion: { (url) in
                guard let url = url else {
                    self.changePictureImageView.alpha = 0.8
                    self.changePictureImageView.backgroundColor = UIColor.clear
                    self.animateChangeButton()
                    return
                }
                self.changePictureImageView.alpha = 0
                self.changePictureImageView.backgroundColor = UIColor.white
                self.userThumbnailImageView.pin_setImage(from: url)
            })
        }
    }
    
    func animateChangeButton() {
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: [], animations: {
            self.changePictureImageView.transform = self.changePictureImageView.transform.scaledBy(x: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.changePictureImageView.transform = .identity
            })
        }
        
        
    }
    
    @objc func didTapThumb() {
        self.delegate?.didTapUserProfileThumb()
    }
    @objc func didTapSettingsButton() {
        self.delegate?.didTapSettingsButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        BSCommons.addShadowTo(view: self.changePictureImageView)
    }
}
