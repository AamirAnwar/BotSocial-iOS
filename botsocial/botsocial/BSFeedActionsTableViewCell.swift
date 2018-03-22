//
//  BSFeedActionsTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
protocol BSFeedActionsTableViewCellDelegate {
    func didTapLikeButton()
}

class BSFeedActionsTableViewCell: UITableViewCell {
    var delegate:BSFeedActionsTableViewCellDelegate?
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
        button.setTitle("No Likes", for: .normal)
        return button
    }()
    
    let dislikeButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("\(arc4random()%200) Dislikes", for: .normal)
        return button
    }()
    
    let commentButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("\(arc4random()%2000) Comments", for: .normal)
        return button
    }()
    
    let saveButton:UIButton = {
        let button = BSFeedActionsTableViewCell.standardButton
        button.setTitle("Save", for: .normal)
        return button
    }()
    var post:BSPost? {
        didSet {
            if let post = self.post {
                APIService.sharedInstance.getLikesForPost(post: post, completion: { (likes) in
                    let pluralCorrection = likes == 1 ? "Like":"Likes"
                    self.likeButton.setTitle("\(likes) \(pluralCorrection)", for: .normal)
                })
                
            }
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.likeButton)
//        self.contentView.addSubview(self.dislikeButton)
        self.contentView.addSubview(self.commentButton)
        self.contentView.addSubview(self.saveButton)
        
        self.selectionStyle = .none
        self.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        self.likeButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
        // Disable Dislikes
        //        self.dislikeButton.snp.makeConstraints { (make) in
//            make.leading.equalTo(self.likeButton.snp.trailing).offset(kInteritemPadding)
//            make.centerY.equalTo(self.likeButton.snp.centerY)
//        }
        
        self.commentButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.likeButton.snp.trailing).offset(kInteritemPadding)
            make.centerY.equalTo(self.likeButton.snp.centerY)
        }
        
        self.saveButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.commentButton.snp.centerY)
            make.leading.greaterThanOrEqualTo(self.commentButton.snp.trailing)
        }
    }
    
    @objc func didTapLikeButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.likeButton.transform = self.likeButton.transform.scaledBy(x: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.likeButton.transform = .identity
            })
        }
        if let post = post {
            APIService.sharedInstance.likePost(post:post)
        }
        self.delegate?.didTapLikeButton()
    }
}
