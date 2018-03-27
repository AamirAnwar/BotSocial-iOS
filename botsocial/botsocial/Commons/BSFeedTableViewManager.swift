//
//  BSFeedTableViewManager.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

struct TableItemInfo {
    var reuseIdentifier:String
    var configHandler:(_ cell:UITableViewCell)->UITableViewCell
}

struct TableDataItem {
    var post:BSPost?
    var info:[TableItemInfo] = []
    
}

protocol BSFeedTableViewManagerDelegate:BSUserSnippetTableViewCellDelegate,BSFeedActionsTableViewCellDelegate {
    var posts:[BSPost] {get set}
    var coachmark:BSCoachmarkView? {get}
    var isLoadingPosts:Bool {get set}
    func postIsSaved(postID: String, saveButton: UIButton)
    func showProfileFor(user:BSUser)
    
}

class BSFeedTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    var delegate:BSFeedTableViewManagerDelegate!
    var dataModel:[TableDataItem] {
        get {
            var model:[TableDataItem] = []
            
                // Add featured section to model
            var item = TableDataItem()
            if self.shouldShowFeaturedSection {
                let featuredPostsInfo = TableItemInfo.init(reuseIdentifier: kFeaturedCellReuseID, configHandler: { (cell) -> UITableViewCell in
                    if let cell = cell as? BSFeaturedPostTableViewCell {
                        cell.featuredPosts = self.delegate.posts
                    }
                    return cell
                })
                item.info.append(featuredPostsInfo)
            }
            model += [item]
            
            
            // Add all posts using map while checking options on the manager
            let posts = self.delegate.posts.map({ (post) -> TableDataItem in
                var item = TableDataItem()
                item.post = post
                // Customize rows in this section here
                
                // User Snippet
                let userSnippetInfo = TableItemInfo.init(reuseIdentifier: kFeedUserSnippetCellReuseID, configHandler: { (cell) -> UITableViewCell in
                    if let cell = cell as? BSUserSnippetTableViewCell {
                        cell.delegate = self.delegate
                        cell.configureWith(post:post)
                        return cell
                    }
                    return cell
                })
                
                item.info += [userSnippetInfo]
                
                // Post Image
                let postImageInfo = TableItemInfo.init(reuseIdentifier: kFeedImageCellReuseID, configHandler: { (cell) -> UITableViewCell in
                    if let cell = cell as? BSImageTableViewCell {
                        cell.setImageURL(post.imageURL)
                    }
                    return cell
                })
                item.info += [postImageInfo]
                
                
                // Post actions
                if self.shouldShowActions {
                    let postActionsInfo = TableItemInfo.init(reuseIdentifier: kFeedActionsCellReuseID, configHandler: { (cell) -> UITableViewCell in
                        if let cell = cell as? BSFeedActionsTableViewCell {
                            cell.delegate = self.delegate
                            cell.post = post
                            cell.saveButton.isSelected = false
                            self.delegate.postIsSaved(postID: post.id, saveButton: cell.saveButton)
                            return cell
                        }
                        return cell
                    })
                    item.info += [postActionsInfo]
                }
                
                // Post detail
                let postDetailInfo = TableItemInfo.init(reuseIdentifier: kFeedPostInfoCellReuseID, configHandler: { (cell) -> UITableViewCell in
                    if let cell = cell as? BSPostDetailTableViewCell {
                        cell.post = post
                    }
                    return cell
                })
                
                item.info += [postDetailInfo]
                return item
            })
            model += posts
            return model
        }
    }
    // Controls whether the featured posts section will be shown
    var shouldShowFeaturedSection = true
    
    // Controls whether like and comment actions are shown
    var shouldShowActions = true

    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.delegate.isLoadingPosts == false else {return 1}
        return 1 + self.delegate.posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.delegate.isLoadingPosts == false else {return 1}
        switch section {
        case 0:
            return self.shouldShowFeaturedSection.intValue
        default:
            return self.shouldShowActions.intValue + 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.delegate.isLoadingPosts == false else {
            return tableView.dequeueReusableCell(withIdentifier: kLoadingCellReuseID)!
        }
        let item = self.dataModel[indexPath.section]
        let itemInfo = item.info[indexPath.row]
        let cellIdentifier = itemInfo.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        return itemInfo.configHandler(cell)
        
        
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

extension Bool {
    var intValue:Int {
        return self ? 1:0
    }
}
