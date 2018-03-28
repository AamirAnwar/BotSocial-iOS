//
//  BSSavedPostsViewController.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import CoreData

class BSSavedPostsViewController: BSBaseViewController {
    var managedContext:NSManagedObjectContext! = DBHelpers.managedContext
    var posts = [BSPost]()
    let tableViewManager = BSFeedTableViewManager()
    var isLoadingPosts: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldShowCoachmark = false
        self.tableViewManager.shouldShowFeaturedSection = false
        self.tableViewManager.delegate = self
        self.tableView.delegate = self.tableViewManager
        self.tableView.dataSource = self.tableViewManager
        self.loadSavedPosts()
    }
    
    func loadSavedPosts() {
        guard let currentUser = APIService.sharedInstance.currentUser else {return}
        let postsFetch:NSFetchRequest<PostObject> = PostObject.fetchRequest()
        postsFetch.predicate = NSPredicate.init(format:"%K == %@", #keyPath(PostObject.user.id), currentUser.uid)
        
        do {
            let results = try managedContext.fetch(postsFetch)
            self.posts = results.map({ (object) -> BSPost in
                let post = BSPost.initWith(postObject: object)
                return post
            })
            self.tableView.reloadData()
        }
        catch let error as NSError {
            print("Fetch Error! \(error)")
        }
    }
    
}
extension BSSavedPostsViewController:BSFeedActionsTableViewCellDelegate {
    func didTapLikeButton(sender:BSFeedActionsTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: sender) {
            let post = self.posts[indexPath.section]
            APIService.sharedInstance.likePost(post:post)
        }
    }
    
    func didTapCommentsButton(sender:BSFeedActionsTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: sender) {
            let post = self.posts[indexPath.section]
            let vc = BSPostCommentsViewController()
            vc.post = post
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTapSavePostButton(sender:BSFeedActionsTableViewCell) {
        let alertController = UIAlertController.init(title: "Delete post", message: "Delete this post?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            if let indexPath = self.tableView.indexPath(for: sender) {
                let postIndex = self.tableViewManager.postIndexForCellAt(indexPath: indexPath)
                let post = self.posts[postIndex]
                // delete post
                self.deletePost(postID: post.id!)
                self.posts.remove(at: postIndex)
                self.tableView.deleteSections(IndexSet.init(integer: indexPath.section), with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            sender.saveButton.isSelected = true
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    func deletePost(postID:String) {
        DBHelpers.deleteSavedPost(postID: postID)
    }
}

extension BSSavedPostsViewController:BSFeedTableViewManagerDelegate {
    
    func showCommentsFor(post: BSPost) {
        let vc = BSPostCommentsViewController()
        vc.post = post
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func postIsSaved(postID: String, saveButton: UIButton) {
        saveButton.isSelected = true
    }
    
    func showProfileFor(user: BSUser) {
        BSCommons.showUser(user: user, navigationController: self.navigationController)
    }
    
    func moreButtonTapped(sender: UITableViewCell) {
        // Do nothing
    }
}
