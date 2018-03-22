//
//  BSPostCommentsViewController.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSPostCommentsViewController: UIViewController, UIGestureRecognizerDelegate {
    let commentTextView = UITextView()
    let postButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let userImageView = UIImageView()
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
    
    var comments:[BSComment] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.commentTextView)
        self.view.addSubview(self.userImageView)
        self.view.addSubview(self.postButton)
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.commentTextView.snp.top).inset(kInteritemPadding)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(BSNotificationTableViewCell.self, forCellReuseIdentifier: kNotifCellReuseID)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
//        self.commentTextView.backgroundColor = UIColor.red
        self.commentTextView.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.postButton.snp.leading).offset(-8)
            make.leading.equalTo(self.userImageView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().inset(kInteritemPadding + self.tabBarHeight)
            make.height.equalTo(50)
        }
        
        self.userImageView.layer.cornerRadius = 22
        APIService.sharedInstance.getUserProfileImageURL { (url) in
            if let url = url {
                self.userImageView.pin_setImage(from: url)
            }
        }
//        self.userImageView.pin_setImage(from: URL(string:kTestImageURL)!)
        self.userImageView.contentMode = .scaleAspectFill
        self.userImageView.clipsToBounds = true
        self.userImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalTo(self.commentTextView.snp.top)
            make.size.equalTo(44)
        }
        
        self.postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        self.postButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.userImageView.snp.centerY)
//            make.bottom.equalToSuperview().inset(kInteritemPadding + self.tabBarHeight)
        }
        
    }
    
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            var tabBarHeight:CGFloat = 0.0
            if let tabbar = self.tabBarController?.tabBar {
                tabBarHeight = tabbar.height()
            }
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight - tabBarHeight, right: 0)
            self.userImageView.transform = userImageView.transform.translatedBy(x: 0, y: -keyboardHeight + tabBarHeight)
            self.commentTextView.transform = commentTextView.transform.translatedBy(x: 0, y: -keyboardHeight + tabBarHeight)
            self.postButton.transform = self.postButton.transform.translatedBy(x: 0, y: -keyboardHeight + tabBarHeight)
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        UIView.animate(withDuration: 1, animations: {
            self.tableView.contentInset = .zero
            self.userImageView.transform = .identity
            self.commentTextView.transform = .identity
            self.postButton.transform = .identity
        })
    }
    
    @objc func didTapPostButton() {
//        post comment
        if let post = self.post, let commentText = self.commentTextView.text {
            APIService.sharedInstance.commentOnPostWith(postID: post.id, comment: commentText) {
                self.commentTextView.text = ""
                self.commentTextView.resignFirstResponder()
            }
        }
    }
    
}

extension BSPostCommentsViewController:UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.commentTextView.isFirstResponder {
            self.commentTextView.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kNotifCellReuseID) as! BSNotificationTableViewCell
        let comment = comments[indexPath.row]
        if let authorImageURL = comment.authorImageURL, let url = URL.init(string: authorImageURL) {
            cell.configureWith(title: comment.text, imageURL: url)
        }
        else if let authorName = comment.authorName, let comment = comment.text {
            cell.configureWith(title: "\(authorName) \(comment)", imageURL: URL(string:kTestImageURL)!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(BSPostViewController(), animated: true)
    }
}
