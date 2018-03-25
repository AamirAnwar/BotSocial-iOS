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

class BSFeedViewController: UIViewController {

    let tableView = UITableView.init(frame: .zero, style: .plain)
    var posts = [BSPost]()
    let kFeedCellReuseIdentifier = "Feed_BSFeedTableViewCell"
    let kFeaturedCellReuseID = "BSFeaturedPostTableViewCell"
    let kFeedImageCellReuseID = "BSImageTableViewCell"
    let kFeedUserSnippetCellReuseID = "BSUserSnippetTableViewCell"
    let kFeedActionsCellReuseID = "BSFeedActionsTableViewCell"
    let kFeedPostInfoCellReuseID = "BSPostDetailTableViewCell"
    let kFeedCommentInfoCellReuseID = "BSAddCommentTableViewCell"
    let coachmarkButton = UIButton.init(type: .system)
    var isShowingCoachmark = false
    var isLoadingPosts = false
    var navBarHeight:CGFloat {
        get {
            if let navBar = self.navigationController?.navigationBar {
                return navBar.height()
            }
            return 0.0
        }
    }
    var managedContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "camera_tab_icon"), style: .plain, target: self, action: #selector(didTapCameraButton))
        self.navigationItem.leftBarButtonItem?.tintColor = BSColorTextBlack
        self.navigationController?.navigationBar.tintColor = BSColorTextBlack
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "chat_icon"), style: .plain, target: self, action: #selector(didTapChatButton))
        self.navigationItem.rightBarButtonItem?.tintColor = BSColorTextBlack
        
        
        self.view.addSubview(self.tableView)
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

        
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCoachmarkButtonHeight, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.delaysContentTouches = false
        self.tableView.register(BSLoaderTableViewCell.self, forCellReuseIdentifier: "loader_cell")
        self.tableView.register(BSFeaturedPostTableViewCell.self, forCellReuseIdentifier: self.kFeaturedCellReuseID)
        self.tableView.register(BSFeedTableViewCell.self, forCellReuseIdentifier: self.kFeedCellReuseIdentifier)
        self.tableView.register(BSUserSnippetTableViewCell.self, forCellReuseIdentifier: kFeedUserSnippetCellReuseID)
        self.tableView.register(BSImageTableViewCell.self, forCellReuseIdentifier: kFeedImageCellReuseID)
        self.tableView.register(BSFeedActionsTableViewCell.self, forCellReuseIdentifier: kFeedActionsCellReuseID)
        self.tableView.register(BSPostDetailTableViewCell.self, forCellReuseIdentifier: kFeedPostInfoCellReuseID)
        self.tableView.register(BSAddCommentTableViewCell.self, forCellReuseIdentifier: kFeedCommentInfoCellReuseID)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        isLoadingPosts = true
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

extension BSFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.isLoadingPosts == false else {return 1}
        return 1 + self.posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.isLoadingPosts == false else {return 1}
        switch section {
        case 0:
            return 1
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.isLoadingPosts == false else {
            return tableView.dequeueReusableCell(withIdentifier: "loader_cell")!
        }
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.kFeaturedCellReuseID) as! BSFeaturedPostTableViewCell
            cell.featuredPosts = self.posts
            return cell
        default:
            let currentPostIndex = indexPath.section - 1
            let post = self.posts[currentPostIndex]
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID) as! BSUserSnippetTableViewCell
                cell.delegate = self
                cell.usernameLabel.text = post.authorName
                cell.moreButton.isHidden = true
                if let authorID = post.authorID {
                    APIService.sharedInstance.getProfilePictureFor(userID: authorID, completion: {(url) in
                        cell.setImageURL(url)
                    })
                    
                    if let currentUser = APIService.sharedInstance.currentUser {
                        if currentUser.uid == authorID {
                            cell.moreButton.isHidden = false
                        }
                        else {
                            cell.moreButton.isHidden = true
                        }
                    }
                }
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedImageCellReuseID) as! BSImageTableViewCell
                cell.setImageURL(post.imageURL)
                cell.delegate = self
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedActionsCellReuseID) as! BSFeedActionsTableViewCell
                cell.delegate = self
                cell.post = post
                cell.indexPath = IndexPath.init(row: indexPath.row, section: currentPostIndex)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedPostInfoCellReuseID) as! BSPostDetailTableViewCell
                cell.post = post
                return cell
            case 4:
                return tableView.dequeueReusableCell(withIdentifier: kFeedCommentInfoCellReuseID)!
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.posts.count > 0 else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0 else {return}
        let postIndex = indexPath.section - 1
        let post = self.posts[postIndex]
        if let authorID = post.authorID {
            switch indexPath.row {
            case 0:
                APIService.sharedInstance.getUserWith(userID: authorID, completion: { (user) in
                    if let user = user {
                        let vc = BSAccountViewController()
                        vc.user = user
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            default:
                break
            }
        }
   
    }
    
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

extension BSFeedViewController:BSImageTableViewCellDelegate {
    func didUpdateCellHeight() {
//        self.tableView.reloadData()
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

