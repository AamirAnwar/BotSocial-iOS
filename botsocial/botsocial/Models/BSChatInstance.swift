//
//  BSChatInstance.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSChatInstance: NSObject {
    var senderID:String!
    var receiver:BSUser!
    static func initWith(senderID:String,receiverID:String, receverInfo:[String:AnyObject]) -> BSChatInstance {
        let chat = BSChatInstance()
        chat.senderID = senderID
        chat.receiver = BSUser.initWith(userID: receiverID, dict: receverInfo)
        return chat
    }
    
}
