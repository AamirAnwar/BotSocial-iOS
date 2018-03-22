//
//  Constants.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

let kCoachmarkButtonWidth:CGFloat = 120
let kCoachmarkButtonHeight:CGFloat = 30
let kUserThumbnailImageHeight:CGFloat = 44
let kSidePadding:CGFloat = 13
let kInteritemPadding:CGFloat = 8
let kCornerRadius:CGFloat = 8
let kLibPhotoPreviewSize:CGFloat = 44
let kNotificationWillShowKeyboard = Notification(name: Notification.Name.UIKeyboardWillShow)
let kNotificationWillHideKeyboard = Notification(name: Notification.Name.UIKeyboardWillHide)

//let kTestImageURL = "https://avatars3.githubusercontent.com/u/12379620?s=460&v=4"
var kTestImageURL:String {
    get {
        return "https://picsum.photos/250/300?random&key=\(arc4random())"
    }
}

var kTestFeaturedImageURL:String {
    get {
        return "https://picsum.photos/808/696?random&key=\(arc4random())"
    }
}

var kTestLargeImageURL:String {
    get {
        return "https://picsum.photos/750/800?random&key=\(arc4random())"
    }
}
