//
//  BSPost.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

let kImageURLKey = "image_url"
let kAuthorIDKey = "uid"
let kAuthorNameKey = "author"
let kCaptionKey = "caption"
class BSPost: NSObject {
    var id:String!
//    var author:BSUser!
    var authorName:String!
    var authorID:String!
    var imageURL:String!
    var caption:String?
    override var description: String {
        get {
            return "id :\(self.id) author:\(self.authorName) authorID:\(self.authorID) imageURL:\(self.imageURL) caption:\(self.caption ?? "")"
        }
    }
    
    static func initWith(postID:String, dict:[String:Any]) -> BSPost {
        let post = BSPost.init()
        post.id = postID
        post.caption = dict[kCaptionKey] as? String ?? ""
        post.imageURL = dict[kImageURLKey] as? String ?? ""
        post.authorID = dict[kAuthorIDKey] as? String ?? ""
        post.authorName = dict[kAuthorNameKey] as? String ?? ""
//        post.author = BSUser.initWith(userID: kAuthorIDKey, dict: dict)
        return post
    }
}


