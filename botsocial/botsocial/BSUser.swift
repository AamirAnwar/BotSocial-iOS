//
//  BSUser.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

let kProfilePictureURLKey = "userPhoto"
let kDisplayNameKey = "display_name"
class BSUser: NSObject {
    var id:String!
    var profilePictureURL:String!
    var email:String?
    var phone:String?
    var displayName:String!
    
    static func initWith(userID:String, dict:[String:String]) -> BSUser{
        let user = BSUser.init()
        user.id = userID
        user.profilePictureURL = dict[kProfilePictureURLKey] ?? ""
        user.displayName = dict[kDisplayNameKey] ?? ""
        return user
    }
}
