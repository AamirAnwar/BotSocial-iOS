//
//  BSAvatarImageDataSource.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class BSAvatarImageDataSource: NSObject {
    var image:UIImage?
    
    func setImageWith(userID:String, completion:@escaping (_ handle:UInt?)->Void) {
        APIService.sharedInstance.getProfilePictureFor(userID: userID, completion: { (url, handle) in
            let imageView = UIImageView()
            imageView.pin_setImage(from: url, placeholderImage: nil, completion: { (result) in
                if let image = result.image {
                    self.image = image
                    completion(handle)
                }
            })
        })
    }
}

extension BSAvatarImageDataSource:JSQMessageAvatarImageDataSource {
    func avatarImage() -> UIImage! {
        return self.image
    }
    
    func avatarHighlightedImage() -> UIImage! {
        return nil
    }
    
    func avatarPlaceholderImage() -> UIImage! {
        return  #imageLiteral(resourceName: "placeholder_image")
    }
}
