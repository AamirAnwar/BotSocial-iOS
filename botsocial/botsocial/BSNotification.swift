//
//  BSNotification.swift
//  Bolts
//
//  Created by Aamir  on 22/03/18.
//

import UIKit

class BSNotification: NSObject {
    var id:String!
    var text:String!
    var userID:String?
    var postID:String!
    static func initWith(notifID:String, notifDict:[String:AnyObject]) -> BSNotification {
        let notif = BSNotification()
        notif.id = notifID
        notif.text = notifDict["text"] as? String ?? ""
        notif.userID = notifDict["user_id"] as? String ?? ""
        notif.postID = notifDict["post_id"] as? String ?? ""
        return notif
    }
}
