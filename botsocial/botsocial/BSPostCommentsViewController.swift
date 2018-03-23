//
//  BSPostCommentsViewController.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSPostCommentsViewController: UIViewController, UIGestureRecognizerDelegate, BSCommentInputViewDelegate {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kNotifCellReuseID = "BSNotificationTableViewCell"
    var tabBarHeight:CGFloat {
        get {
            if let tabBar = self.tabBarController?.tabBar {
                return tabBar.height()
            }
            return 0.0
        }
    }
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
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.commentView)
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        
        self.navigationItem.title = "Comments"
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.commentView.snp.top).inset(kInteritemPadding)
        }
        
        self.commentView.delegate = self
        self.commentView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(tabBarHeight)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(BSNotificationTableViewCell.self, forCellReuseIdentifier: kNotifCellReuseID)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            var tabBarHeight:CGFloat = 0.0
            if let tabbar = self.tabBarController?.tabBar {
                tabBarHeight = tabbar.height()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight - tabBarHeight, right: 0)
                self.commentView.transform = self.commentView.transform.translatedBy(x: 0, y: -keyboardHeight + tabBarHeight)
            })
            
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.contentInset = .zero
            self.commentView.transform = .identity
        })
    }
    
    @objc func didTapPostButton() {
        if let post = self.post, let commentText = self.commentView.commentTextView.text {
            APIService.sharedInstance.commentOnPostWith(post: post, comment: commentText) {
                self.commentView.commentTextView.text = ""
                self.commentView.commentTextView.resignFirstResponder()
            }
        }
    }
    
    
    
    
}

extension BSPostCommentsViewController:UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.commentView.commentTextView.isFirstResponder {
            self.commentView.commentTextView.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kNotifCellReuseID) as! BSNotificationTableViewCell
        let comment = comments[indexPath.row]
        
        if let authorName = comment.authorName, let commentText = comment.text {
            cell.configureWith(authorName:authorName,title: commentText)
            APIService.sharedInstance.getProfilePictureFor(userID: comment.authorID, completion: { (url) in
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
