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
    let coachmarkButton = UIButton.init(type: .system)
    var isShowingCoachmark = false
    var isLoadingPosts = false
    var managedContext:NSManagedObjectContext!
    let feedTableViewManager = BSFeedTableViewManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationItem()
        self.configureCoachmarkButton()
        self.observePosts()
    }
    
    func observePosts() {
        self.isLoadingPosts = true
        APIService.sharedInstance.getRecentPosts { (post) in
            if let post = post {
                self.posts.insert(post, at: 0)
                
                // If in between the list then show coachmark
                if let indexPaths = self.tableView.indexPathsForVisibleRows {
                    var min = Int.max
                    for path in indexPaths {
                        if path.section < min {
                            min = path.section
                        }
                    }
                    if min > 2 {
                        self.showCoachmark(withTitle: kCoachmarkTitleNewPost)
                    }
                    
                }
            }
            self.isLoadingPosts = false
            self.tableView.reloadData()
            
        }
    }
    
    func configureCoachmarkButton() {
        self.view.addSubview(self.coachmarkButton)
        self.coachmarkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.coachmarkButton.frame = CGRect.init(x: (view.width() - kCoachmarkButtonWidth)/2, y: view.height(), width: kCoachmarkButtonWidth, height: kCoachmarkButtonHeight)
        self.coachmarkButton.setTitle("Back to top", for: .normal)
        self.coachmarkButton.layer.cornerRadius = kCoachmarkButtonHeight/2
        self.coachmarkButton.backgroundColor = UIColor.white
        self.coachmarkButton.titleLabel?.font = BSFontMiniBold
        self.coachmarkButton.setTitleColor(BSColorTextBlack, for: .normal)
        self.coachmarkButton.addTarget(self, action: #selector(didTapCoachmark), for: .touchUpInside)
        BSCommons.addShadowTo(view:self.coachmarkButton)

    }
    
    func configureNavigationItem() {
        self.navigationItem.title = "Home"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "camera_tab_icon"), style: .plain, target: self, action: #selector(didTapCameraButton))
        self.navigationItem.leftBarButtonItem?.tintColor = BSColorTextBlack
        self.navigationController?.navigationBar.tintColor = BSColorTextBlack
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "chat_icon"), style: .plain, target: self, action: #selector(didTapChatButton))
        self.navigationItem.rightBarButtonItem?.tintColor = BSColorTextBlack
    }
    
    
    override func configureTableView() {
        super.configureTableView()
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCoachmarkButtonHeight, right: 0)
        self.feedTableViewManager.delegate = self
        self.tableView.delegate = self.feedTableViewManager
        self.tableView.dataSource = self.feedTableViewManager
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

extension BSFeedViewController {
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y + scrollView.height() < (scrollView.contentSize.height) {
            hideCoachmark()
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y + scrollView.height() >= (scrollView.contentSize.height) {
            // Show coachmark
            showCoachmark(withTitle: kCoachmarkTitleScrollUp)
        }
        else {
            hideCoachmark()
        }
    }
    
    func showCoachmark(withTitle title:String) {
        guard self.posts.count > 1 && isShowingCoachmark == false else {return}
        self.coachmarkButton.setTitle(title, for: .normal)
        UIView.animate(withDuration: 0.3, animations: {
            self.coachmarkButton.frame = CGRect.init(x: (self.view.width() - self.coachmarkButton.width())/2, y: self.view.height() - 44 - kInteritemPadding - self.coachmarkButton.height() - 4, width: self.coachmarkButton.width(), height: self.coachmarkButton.height())
        }) { (_) in
            self.isShowingCoachmark = true
        }
        
    }
    
    func hideCoachmark() {
        guard isShowingCoachmark == true else {return}
        UIView.animate(withDuration: 0.3, animations: {
            self.coachmarkButton.frame = CGRect.init(x: (self.view.width() - self.coachmarkButton.width())/2, y: self.view.height(), width: self.coachmarkButton.width(), height: self.coachmarkButton.height())
        }) { (_) in
            self.isShowingCoachmark = false
        }
    }
    @objc func didTapCoachmark() {
//        self.tableView.setContentOffset(CGPoint.init(x: 0, y: -(self.navBarHeight + self.tableView.contentInset.bottom + self.tableView.contentInset.top)), animated: true)
        self.tableView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: true)
        self.hideCoachmark()
    }
    
}

extension BSFeedViewController:BSFeedActionsTableViewCellDelegate {
    func didTapLikeButton(forIndexPath indexPath: IndexPath?) {
        if let indexPath = indexPath {
            let post = self.posts[indexPath.section]
            APIService.sharedInstance.likePost(post:post)
        }
    }
    
    func didTapCommentsButton(forIndexPath indexPath: IndexPath?) {
        if let indexPath = indexPath {
            let post = self.posts[indexPath.section]
            let vc = BSPostCommentsViewController()
            vc.post = post
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
   
    
    func didTapSavePostButton(forIndexPath indexPath: IndexPath?) {
        guard let currentUser = APIService.sharedInstance.currentUser  else {return }
        if let indexPath = indexPath {
            let post = self.posts[indexPath.section]
            do {
                let userFetch:NSFetchRequest<UserObject> = UserObject.fetchRequest()
                userFetch.predicate = NSPredicate.init(format:"%K == %@", #keyPath(UserObject.id), currentUser.uid)
                
                let results = try managedContext.fetch(userFetch)
                if results.count > 0 {
                    guard let currentUserObject = results.first else {
                        return
                    }
                    if let savedPosts = currentUserObject.posts as? NSMutableOrderedSet {
                        let entityDesc = NSEntityDescription.entity(forEntityName: "PostObject", in: managedContext)!
                        let savedPost = PostObject.init(entity: entityDesc, insertInto: managedContext)
                        savedPost.id = post.id
                        savedPost.imageURL = post.imageURL
                        savedPost.authorName = post.authorName
                        savedPost.caption = post.caption
                        savedPost.authorID = post.authorID
                        savedPost.user = currentUserObject
                        savedPosts.add(savedPost)
                        
                        currentUserObject.posts = savedPosts
                    }
                    
                 try managedContext.save()
                }
            }
            catch let error as NSError {
                print("Fetch error \(error)")
            }
            
        }
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

extension BSFeedViewController:BSFeedTableViewManagerDelegate {

    func showProfileFor(user: BSUser) {
        let vc = BSAccountViewController()
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func postIsSaved(postID:String, saveButton:UIButton){
        guard let currentUser = APIService.sharedInstance.currentUser else {return}
        let postsFetch:NSFetchRequest<PostObject> = PostObject.fetchRequest()
        postsFetch.predicate = NSPredicate.init(format:"%K == %@", #keyPath(PostObject.user.id), currentUser.uid)
        let asyncFetch:NSAsynchronousFetchRequest<PostObject> = NSAsynchronousFetchRequest<PostObject>.init(fetchRequest: postsFetch) {(result) in
            if let finalResult = result.finalResult {
                for post in finalResult {
                    if post.id == postID {
                        saveButton.isSelected = true
                    }
                }
            }
        }
        do {
            try managedContext.execute(asyncFetch)
        }
        catch let error as NSError {
            print("Fetch Error! \(error)")
            return
        }
        return
        
    }
}

