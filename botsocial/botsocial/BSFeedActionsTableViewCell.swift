//
//  BSFeedActionsTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
protocol BSFeedActionsTableViewCellDelegate {
    func didTapLikeButton(forIndexPath indexPath:IndexPath?)
    func didTapCommentsButton(forIndexPath indexPath:IndexPath?)
    func didTapSavePostButton(forIndexPath indexPath:IndexPath?)
}

class BSFeedActionsTableViewCell: UITableViewCell {
    var delegate:BSFeedActionsTableViewCellDelegate?
    var indexPath:IndexPath?
    static var standardButton:UIButton {
        get {
            let button = UIButton.init(type: .system)
            button.titleLabel?.font = BSFontMediumBold
            button.layer.cornerRadius = kCornerRadius
            button.setTitleColor(BSColorTextBlack, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 4)
            return button
        }
    }
    
    let likeActionButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.setBackgroundImage(#imageLiteral(resourceName: "like_icon_normal"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "like_icon_highlighted"), for: .selected)
        button.snp.makeConstraints({ (make) in
            make.size.equalTo(22)
        })
        return button
    }()
    
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
        button.setTitle("No Comments", for: .normal)
        return button
    }()
    
    let saveButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.setBackgroundImage(#imageLiteral(resourceName: "save_icon_normal"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "save_icon_highlighted"), for: .selected)
        button.snp.makeConstraints({ (make) in
            make.size.equalTo(22)
        })
        return button
    }()
    var post:BSPost? {
        didSet {
            if let post = self.post {
                APIService.sharedInstance.getLikesForPost(post: post, completion: { (likes) in
                    let pluralCorrection = likes == 1 ? "Like":"Likes"
                    self.likeButton.setTitle("\(likes) \(pluralCorrection)", for: .normal)
                })
                
                APIService.sharedInstance.getCommentCountForPost(post: post, completion: { (commentCount) in
                    let pluralCorrection = commentCount == 1 ? "Comment":"Comments"
                    self.commentButton.setTitle("\(commentCount) \(pluralCorrection)", for: .normal)
                })
                
                APIService.sharedInstance.isPostLiked(post: post, completion: { (isLiked) in
                    self.likeActionButton.isSelected = isLiked
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
        self.contentView.addSubview(self.likeActionButton)
        
        self.selectionStyle = .none
        self.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        self.likeButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.likeActionButton.snp.trailing).offset(4)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(0)
        }
        // Disable Dislikes
        //        self.dislikeButton.snp.makeConstraints { (make) in
//            make.leading.equalTo(self.likeButton.snp.trailing).offset(kInteritemPadding)
//            make.centerY.equalTo(self.likeButton.snp.centerY)
//        }
        self.commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        self.commentButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.likeButton.snp.trailing).offset(kInteritemPadding)
            make.centerY.equalTo(self.likeButton.snp.centerY)
        }
        self.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        self.saveButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.commentButton.snp.centerY)
            make.leading.greaterThanOrEqualTo(self.commentButton.snp.trailing)
        }
        
        self.likeActionButton.addTarget(self, action: #selector(didTapLikeActionButton), for: .touchUpInside)
        self.likeActionButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.centerY.equalTo(self.likeButton.snp.centerY)
        }
    }
    
    @objc func commentButtonTapped() {
        
        self.delegate?.didTapCommentsButton(forIndexPath: self.indexPath)
    }
    
    @objc func didTapLikeActionButton() {
        UIView.transition(with: self.likeActionButton, duration: 0.3, options: .curveEaseIn, animations: {
            self.likeActionButton.isSelected = !self.likeActionButton.isSelected
        })
        UIView.animate(withDuration: 0.3, animations: {
            self.likeActionButton.transform = self.likeActionButton.transform.scaledBy(x: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.likeActionButton.transform = .identity
            })
        }
        self.delegate?.didTapLikeButton(forIndexPath: self.indexPath)
    }
    
    @objc func didTapLikeButton() {
        self.didTapLikeActionButton()
    }
    
    @objc func saveButtonTapped() {
        UIView.transition(with: self.saveButton, duration: 0.3, options: .curveEaseIn, animations: {
            self.saveButton.isSelected = !self.saveButton.isSelected
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            self.saveButton.transform = self.saveButton.transform.scaledBy(x: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.saveButton.transform = .identity
            })
        }
        self.delegate?.didTapSavePostButton(forIndexPath: indexPath)
    }
}
