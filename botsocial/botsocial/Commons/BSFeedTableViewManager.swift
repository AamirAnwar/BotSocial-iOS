//
//  BSFeedTableViewManager.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

protocol BSFeedTableViewManagerDelegate:BSUserSnippetTableViewCellDelegate,BSFeedActionsTableViewCellDelegate {
    var posts:[BSPost] {get set}
    var coachmark:BSCoachmarkView? {get}
    var isLoadingPosts:Bool {get set}
    func postIsSaved(postID: String, saveButton: UIButton)
    func showProfileFor(user:BSUser)
    
}

class BSFeedTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    var delegate:BSFeedTableViewManagerDelegate!
    var shouldShowFeaturedSection = true
    
    private var isShowingFeaturedSection:Int {
        return self.shouldShowFeaturedSection ? 1:0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
    guard self.delegate.isLoadingPosts == false else {return 1}
    return 1 + self.delegate.posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.delegate.isLoadingPosts == false else {return 1}
        switch section {
        case 0:
            return isShowingFeaturedSection
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.delegate.isLoadingPosts == false else {
            return tableView.dequeueReusableCell(withIdentifier: kLoadingCellReuseID)!
        }
        switch indexPath.section {
        case 0:
            // Featured posts
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedCellReuseID) as! BSFeaturedPostTableViewCell
            cell.featuredPosts = self.delegate.posts
            return cell
        default:
            // General Feed
            let currentPostIndex = indexPath.section - 1
            let post = self.delegate.posts[currentPostIndex]
            switch indexPath.row {
            case 0:
                // User Snippet
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID) as! BSUserSnippetTableViewCell
                cell.delegate = self.delegate
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
                // Post Image
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedImageCellReuseID) as! BSImageTableViewCell
                cell.setImageURL(post.imageURL)
                return cell
            case 2:
                // Post Actions
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedActionsCellReuseID) as! BSFeedActionsTableViewCell
                cell.delegate = self.delegate
                cell.post = post
                cell.indexPath = IndexPath.init(row: indexPath.row, section: currentPostIndex)
                cell.saveButton.isSelected = false
                self.delegate.postIsSaved(postID: post.id, saveButton: cell.saveButton)
                return cell
            case 3:
                // Post Detail
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedPostInfoCellReuseID) as! BSPostDetailTableViewCell
                cell.post = post
                return cell
            case 4:
                // Post comment
                return tableView.dequeueReusableCell(withIdentifier: kFeedCommentInfoCellReuseID)!
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.delegate.posts.count > 0 else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0 else {return}
        let postIndex = indexPath.section - 1
        let post = self.delegate.posts[postIndex]
        if let authorID = post.authorID {
            switch indexPath.row {
            case 0:
                APIService.sharedInstance.getUserWith(userID: authorID, completion: { (user) in
                    if let user = user {
                        self.delegate.showProfileFor(user:user)
                    }
                })
            default:
                break
            }
        }
        
    }
    
    func postIndexForCellAt(indexPath:IndexPath) -> Int {
        return indexPath.section - 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y + scrollView.height() < (scrollView.contentSize.height) {
            self.delegate.coachmark?.hide()
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y + scrollView.height() >= (scrollView.contentSize.height) {
            // Show coachmark
            self.delegate.coachmark?.show(withTitle: kCoachmarkTitleScrollUp)
        }
        else {
            self.delegate.coachmark?.hide()
        }
    }
}
