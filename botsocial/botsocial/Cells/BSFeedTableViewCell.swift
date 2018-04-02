//
//  BSFeedTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit
import PINRemoteImage

class BSFeedTableViewCell: UITableViewCell {
    
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kFeedImageCellReuseID = "BSImageTableViewCell"
    let kFeedUserSnippetCellReuseID = "BSUserSnippetTableViewCell"
    let kFeedActionsCellReuseID = "BSFeedActionsTableViewCell"
    let kFeedPostInfoCellReuseID = "BSPostDetailTableViewCell"
    let kFeedCommentInfoCellReuseID = "BSAddCommentTableViewCell"
    var imageURLString:String?
    var post:BSPost?
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delaysContentTouches = false
        self.tableView.tableFooterView = UIView.init()
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(700)
        }
        self.tableView.register(BSUserSnippetTableViewCell.self, forCellReuseIdentifier: kFeedUserSnippetCellReuseID)
        self.tableView.register(BSImageTableViewCell.self, forCellReuseIdentifier: kFeedImageCellReuseID)
        self.tableView.register(BSFeedActionsTableViewCell.self, forCellReuseIdentifier: kFeedActionsCellReuseID)
        self.tableView.register(BSPostDetailTableViewCell.self, forCellReuseIdentifier: kFeedPostInfoCellReuseID)
        self.tableView.register(BSAddCommentTableViewCell.self, forCellReuseIdentifier: kFeedCommentInfoCellReuseID)
        
    }
    
    func configureWith(post:BSPost) {
        self.post = post
        self.tableView.reloadData()
    }
    
    
}

extension BSFeedTableViewCell:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID) as! BSUserSnippetTableViewCell
            if let post = self.post {
                APIService.sharedInstance.getProfilePictureFor(userID: post.authorID, completion: {[weak cell] (url, handle) in
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
            cell.setImageURL(self.post?.imageURL ?? "")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedActionsCellReuseID) as! BSFeedActionsTableViewCell
//            cell.delegate = self
            cell.post = self.post
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
}
//
//extension BSFeedTableViewCell:BSFeedActionsTableViewCellDelegate {
//    func didTapLikeButton() {
//        if let post = post {
//            APIService.sharedInstance.likePost(post:post)
//        }
//    }
//
//
//}

