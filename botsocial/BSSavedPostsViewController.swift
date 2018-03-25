//
//  BSSavedPostsViewController.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import CoreData

class BSSavedPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var managedContext:NSManagedObjectContext! = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.managedContext
    var posts = [PostObject]()
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kFeedCellReuseIdentifier = "Feed_BSFeedTableViewCell"
    let kFeaturedCellReuseID = "BSFeaturedPostTableViewCell"
    let kFeedImageCellReuseID = "BSImageTableViewCell"
    let kFeedUserSnippetCellReuseID = "BSUserSnippetTableViewCell"
    let kFeedActionsCellReuseID = "BSFeedActionsTableViewCell"
    let kFeedPostInfoCellReuseID = "BSPostDetailTableViewCell"
    let kFeedCommentInfoCellReuseID = "BSAddCommentTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(self.tableView)
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
        
        self.loadSavedPosts()
    }
    
    func loadSavedPosts() {
        guard let currentUser = APIService.sharedInstance.currentUser else {return}
        let postsFetch:NSFetchRequest<PostObject> = PostObject.fetchRequest()
        postsFetch.predicate = NSPredicate.init(format:"%K == %@", #keyPath(PostObject.user.id), currentUser.uid)
        
        do {
            let results = try managedContext.fetch(postsFetch)
            self.posts = results
            self.tableView.reloadData()
        }
        catch let error as NSError {
            print("Fetch Error! \(error)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentPostIndex = indexPath.section
        let post = self.posts[currentPostIndex]
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID) as! BSUserSnippetTableViewCell
            //                cell.delegate = self
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
//            cell.delegate = self
            if let imageURL = post.imageURL {
                cell.setImageURL(imageURL)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedActionsCellReuseID) as! BSFeedActionsTableViewCell
            let savedPost = posts[indexPath.section]
            let post = BSPost()
            post.authorID = savedPost.authorID
            post.authorName = savedPost.authorName
            post.id = savedPost.id
            post.caption = savedPost.caption
            cell.post = post
            cell.indexPath = IndexPath.init(row: indexPath.row, section: currentPostIndex)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedPostInfoCellReuseID) as! BSPostDetailTableViewCell
            let savedPost = posts[indexPath.section]
            let post = BSPost()
            post.authorID = savedPost.authorID
            post.authorName = savedPost.authorName
            post.id = savedPost.id
            post.caption = savedPost.caption
            cell.post = post
            return cell
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: kFeedCommentInfoCellReuseID)!
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.posts.count > 0 else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0 else {return}
        let postIndex = indexPath.section
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

}
