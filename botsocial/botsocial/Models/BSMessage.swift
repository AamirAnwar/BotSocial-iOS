//
//  BSMessage.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSMessage: NSObject {
    var id:String!
    var text:String!
    var senderID:String!
    var senderName:String!
    var chatID:String!
    
    static func initWith(id:String, dict:[String:AnyObject]) -> BSMessage{
        let message = BSMessage()
        message.id = id
        message.senderID = dict["sender_id"] as! String
        message.senderName = dict["sender_name"] as! String
        message.text = dict["text"] as! String
        message.chatID = dict["chat_id"] as! String
        return message
    }
    
}
