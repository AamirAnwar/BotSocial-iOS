//
//  BSFeedViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit
import CoreData

class BSFeedViewController: BSBaseViewController {
    var posts = [BSPost]()
    var isLoadingPosts = false
    var managedContext:NSManagedObjectContext!
    let feedTableViewManager = BSFeedTableViewManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldShowCoachmark = true
        self.configureNavigationItem()
        self.observePosts()
    }
    
    func observePosts() {
        self.isLoadingPosts = true
        APIService.sharedInstance.getRecentPosts { (post, handle) in
            self.addHandle(handle)
            if let post = post {
                self.posts.insert(post, at: 0)
                
                // If in between the list then show coachmark. Still a work in progress
                if let indexPaths = self.tableView.indexPathsForVisibleRows {
                    var min = Int.max
                    for path in indexPaths {
                        if path.section < min {
                            min = path.section
                        }
                    }
                    if min > 2 {
                        self.coachmark?.show(withTitle: kCoachmarkTitleNewPost)
                    }
                    
                }
            }
            self.isLoadingPosts = false
            self.tableView.reloadData()
            
        }
    }
    
    override func configureTableView() {
        super.configureTableView()
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCoachmarkButtonHeight, right: 0)
        self.feedTableViewManager.delegate = self
        self.tableView.delegate = self.feedTableViewManager
        self.tableView.dataSource = self.feedTableViewManager
    }

}

// MARK:Configure Navigation Bar
extension BSFeedViewController {
    
    func configureNavigationItem() {
        self.navigationItem.title = "Home"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "camera_tab_icon"), style: .plain, target: self, action: #selector(didTapCameraButton))
        self.navigationItem.leftBarButtonItem?.tintColor = BSColorTextBlack
        self.navigationController?.navigationBar.tintColor = BSColorTextBlack
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "chat_icon"), style: .plain, target: self, action: #selector(didTapChatButton))
        self.navigationItem.rightBarButtonItem?.tintColor = BSColorTextBlack
    }
    
    @objc func didTapCameraButton() {
        let navVC = UINavigationController.init(rootViewController: BSCameraViewController())
        self.present(navVC, animated: true)
    }
    
    @objc func didTapChatButton() {
        guard let _ = APIService.sharedInstance.currentUser else {return}
        let vc = BSChatListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BSFeedViewController:BSUserSnippetTableViewCellDelegate {
    func moreButtonTapped(sender:UITableViewCell) {
        let alertController = UIAlertController.init(title: "Delete post", message: "Delete this post?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            if let indexPath = self.tableView.indexPath(for: sender) {
                let post = self.posts[indexPath.section - 1]
                APIService.sharedInstance.deletePost(post: post, completion: {
                    self.tableView.reloadData()
                })
            }
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
// MARK: Saved Posts
extension BSFeedViewController {
    func postIsSaved(postID:String, saveButton:UIButton) {
        DBHelpers.isPostSaved(postID: postID) { (isSaved) in
            saveButton.isSelected = isSaved
        }
    }
}

extension BSFeedViewController:BSFeedTableViewManagerDelegate {
    
    func didTapSavePostButton(sender:BSFeedActionsTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: sender) {
            let index = self.feedTableViewManager.postIndexForCellAt(indexPath: indexPath)
            let post = self.posts[index]
            DBHelpers.savePost(post: post)
        }
    }
    
    func showCommentsFor(post:BSPost) {
        let vc = BSPostCommentsViewController()
        vc.post = post
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfileFor(user: BSUser) {
        BSCommons.showUser(user: user, navigationController: self.navigationController)
    }
}

