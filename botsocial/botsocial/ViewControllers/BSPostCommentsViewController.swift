//
//  BSPostCommentsViewController.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSPostCommentsViewController: BSBaseViewController, BSCommentInputViewDelegate {
    let kNotifCellReuseID = "BSNotificationTableViewCell"
    var post:BSPost? {
        didSet {
            self.comments = []
            if let post = self.post {
                APIService.sharedInstance.getCommentsForPostWith(postID: post.id, completion: { (comment) in
                    self.comments += [comment]
                    self.tableView.reloadData()
                })
            }
        }
    }
    let commentView = BSCommentInputView()
    var comments:[BSComment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.commentView)
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Comments"
        self.enableKeyboardListeners()
        self.commentView.delegate = self
        self.commentView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(tabBarHeight)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.commentView.snp.top).inset(kInteritemPadding)
        }
    }
    
    override func configureTableView() {
        super.configureTableView()
        self.tableView.register(BSNotificationTableViewCell.self, forCellReuseIdentifier: kNotifCellReuseID)
    }
    
    
    override func willShowKeyboardWith(height: CGFloat) {
        super.willShowKeyboardWith(height: height)
        UIView.animate(withDuration: 0.3, animations: {
            self.commentView.transform = self.commentView.transform.translatedBy(x: 0, y: -height)
        })
    }

    
    override func willHideKeyboardWith(height: CGFloat) {
        super.willHideKeyboardWith(height: height)
        UIView.animate(withDuration: 0.3, animations: {
            self.commentView.transform = .identity
        })
    }
    
    @objc func didTapPostButton() {
        if let post = self.post, let commentText = self.commentView.commentTextView.text, commentText.isEmpty == false && commentText != kCommentPlaceholderText {
            APIService.sharedInstance.commentOnPostWith(post: post, comment: commentText) {
                self.commentView.commentTextView.text = ""
                self.commentView.commentTextView.resignFirstResponder()
            }
        }
    }
}

extension BSPostCommentsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.commentView.commentTextView.isFirstResponder {
            self.commentView.commentTextView.resignFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kNotifCellReuseID) as! BSNotificationTableViewCell
        let comment = comments[indexPath.row]
        
        if let authorName = comment.authorName, let commentText = comment.text {
            cell.configureWith(authorName:authorName,title: commentText)
            APIService.sharedInstance.getProfilePictureFor(userID: comment.authorID, completion: { (url, handle) in
                self.addHandle(handle)
                cell.userThumbnailImageView.pin_setImage(from: url)
            })
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let comment = comments[indexPath.row]
        if let authorID = comment.authorID {
            APIService.sharedInstance.getUserWith(userID: authorID, completion: { (user) in
                let vc = BSAccountViewController()
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        
    }
}
