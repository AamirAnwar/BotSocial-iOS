//
//  BSComment.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSComment: NSObject {
    var id:String!
    var text:String!
    var authorName:String!
    var authorImageURL:String?
    var authorID:String!
    static func initWith(commentID:String, dict:[String:AnyObject]) -> BSComment{
        let comment = BSComment()
        comment.id = commentID
        comment.text = dict["text"] as? String ?? ""
        comment.authorID = dict["author_id"] as? String ?? ""
        comment.authorName = dict["author_name"] as? String ?? ""
        return comment
    }
 }
