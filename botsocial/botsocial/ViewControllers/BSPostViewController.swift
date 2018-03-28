//
//  BSPostViewController.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSPostViewController: UITableViewController, UIGestureRecognizerDelegate {
    let kFeedImageCellReuseID = "BSImageTableViewCell"
    let kFeedUserSnippetCellReuseID = "BSUserSnippetTableViewCell"
    let kFeedActionsCellReuseID = "BSFeedActionsTableViewCell"
    let kFeedPostInfoCellReuseID = "BSPostDetailTableViewCell"
    let kFeedCommentInfoCellReuseID = "BSAddCommentTableViewCell"
    var post:BSPost? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(BSUserSnippetTableViewCell.self, forCellReuseIdentifier: kFeedUserSnippetCellReuseID)
        self.tableView.register(BSImageTableViewCell.self, forCellReuseIdentifier: kFeedImageCellReuseID)
        self.tableView.register(BSFeedActionsTableViewCell.self, forCellReuseIdentifier: kFeedActionsCellReuseID)
        self.tableView.register(BSPostDetailTableViewCell.self, forCellReuseIdentifier: kFeedPostInfoCellReuseID)
        self.tableView.register(BSAddCommentTableViewCell.self, forCellReuseIdentifier: kFeedCommentInfoCellReuseID)
        self.tableView.delaysContentTouches = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID) as! BSUserSnippetTableViewCell
            if let post = self.post {
                cell.usernameLabel.text = self.post?.authorName
                APIService.sharedInstance.getProfilePictureFor(userID: post.authorID, completion: { (url) in
                    cell.setImageURL(url)
                })
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedImageCellReuseID) as! BSImageTableViewCell
            if let post = self.post, let imageURLString = post.imageURL {
                cell.setImageURL(imageURLString)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedActionsCellReuseID) as! BSFeedActionsTableViewCell
            cell.post = self.post
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedPostInfoCellReuseID) as! BSPostDetailTableViewCell
            cell.post = self.post
            return cell
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: kFeedCommentInfoCellReuseID)!
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if let authorID = self.post?.authorID {
                APIService.sharedInstance.getUserWith(userID: authorID, completion: { (user) in
                    let vc = BSAccountViewController()
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
}

extension BSPostViewController:BSFeedActionsTableViewCellDelegate {
    func didTapLikeButton(sender: BSFeedActionsTableViewCell) {
        if  let post = self.post {
            APIService.sharedInstance.likePost(post:post)
        }
    }
    
    func didTapCommentsButton(sender: BSFeedActionsTableViewCell) {
        if let post = self.post {
            let vc = BSPostCommentsViewController()
            vc.post = post
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTapSavePostButton(sender: BSFeedActionsTableViewCell) {
        if let post = self.post {
            DBHelpers.savePost(post: post)
        }
    }
}

