//
//  BSFeedViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "camera_tab_icon"), style: .plain, target: self, action: #selector(didTapCameraButton))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delaysContentTouches = false
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
        
        APIService.sharedInstance.getRecentPosts { (post) in
            if let post = post {
                self.posts += [post]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
//        for _ in 0..<20 {
//            postImages += [kTestLargeImageURL]
//        }
    }
    
    @objc func didTapCameraButton() {
        let navVC = UINavigationController.init(rootViewController: BSCameraViewController())
        self.present(navVC, animated: true)
    }
}

extension BSFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + self.posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 4
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: self.kFeaturedCellReuseID)!
        default:
            let currentPostIndex = indexPath.section - 1
            let post = self.posts[currentPostIndex]
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID) as! BSUserSnippetTableViewCell
                if let authorID = post.authorID {
                    APIService.sharedInstance.getProfilePictureFor(userID: authorID, completion: {[weak cell] (url) in
                        if let strongCell = cell {
                            if let url = url {
                                strongCell.setImageURL(url)
                            }
                        }
                    })
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedImageCellReuseID) as! BSImageTableViewCell
                cell.setImageURL(post.imageURL ?? "")
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y + scrollView.height() >= (scrollView.contentSize.height - 10) {
            // Show coachmark
            
        }
    }
    
    func showCoachmark() {
        
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
    
    
    
}

