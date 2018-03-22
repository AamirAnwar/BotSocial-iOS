//
//  APIService.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import Firebase

class APIService: NSObject {
    static let sharedInstance = APIService()
    fileprivate let storageRef = Storage.storage().reference()
    fileprivate let databaseRef = Database.database().reference()
    fileprivate var currentUser:User? {
        get {
            return Auth.auth().currentUser
        }
    }
    public var isLoggedIn:Bool {
        get {
            return Auth.auth().currentUser != nil
        }
    }
    
    func getUserPosts(completion:@escaping ((_ posts:[String]) -> Void)) {
        guard let user = self.currentUser else {return}
        self.databaseRef.child("user-posts").child("\(user.uid)").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String:AnyObject]
//            print("Fetching user posts!")
            if let dict = value {
                let images = dict.values.map({ (post) -> String in
                    if let subdict = post as? [String:String] {
                        return "\(subdict["image_url"] ?? "")"
                    }
                    return ""
                })
//                print("Parsed images array! \(images)")
                completion(images)
            }
            else {
                completion([])
            }
        })
    }
    
    func getRecentPosts(completion:@escaping ((_ posts:BSPost?) -> Void)) {
        guard let _ = self.currentUser else {return}
        self.databaseRef.child("posts").observe(DataEventType.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:AnyObject] else {completion(nil);return}
            let post = BSPost.initWith(postID: snapshot.key, dict: dict)
            completion(post)
        })
    }
    
    func getUserProfileImageURL(completion:@escaping ((_ url:URL?)->Void)) {
        guard let user = self.currentUser else {completion(nil);return}
        self.databaseRef.child("users").child(user.uid).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value ?? "")
            let profileImageURL = value?["userPhoto"] as? String ?? ""
            print("Profile image url is \(profileImageURL)")
            completion(URL(string:profileImageURL))
        })
    }
    
    func getProfilePictureFor(userID:String,completion:@escaping ((_ url:URL?)->Void)) {
        guard userID.isEmpty == false else {completion(nil);return}
        self.databaseRef.child("users").child(userID).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let profileImageURL = value?["userPhoto"] as? String ?? ""
            completion(URL(string:profileImageURL))
        })
    }
    
    
    
    func updateUserProfilePicture(image:UIImage, completion:@escaping()->Void) {
        if let user = self.currentUser {
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            let filePath = "\(user.uid)/\("userPhoto")"
            let storageRef = Storage.storage().reference()
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageRef.child(filePath).putData(imageData, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                else {
                    //store downloadURL
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    print("Upload successful!")
                    print(downloadURL)
                    //store downloadURL at database
                    self.databaseRef.child("users").child(user.uid).updateChildValues(["userPhoto": downloadURL], withCompletionBlock: { (error, ref) in
                        completion()
                    })
                }
                
            }
        }
    }
    
    
    func createPost(caption:String? = String(), image:UIImage, completion:@escaping (() -> Void)) {
        guard let user = self.currentUser else {return}
        let postKey = self.databaseRef.child("posts").childByAutoId().key
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        let filePath = "\(postKey)"
        let storageRef = Storage.storage().reference()
        let metaData = StorageMetadata()
        
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(imageData, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else {
                let downloadURL = metaData!.downloadURL()!.absoluteString
                
                let post = ["uid": user.uid,
                            "author": user.displayName!,
                            "caption": caption,
                            "image_url": downloadURL
                ]
                let childUpdates = ["/posts/\(postKey)": post,
                                    "/user-posts/\(user.uid)/\(postKey)/": post]
                self.databaseRef.updateChildValues(childUpdates)
            }
            completion()
        }
    }
    
    func likePost(post:BSPost) {
        guard let user = self.currentUser, let postID = post.id else {return}
        
        self.databaseRef.child("/posts/\(postID)/likes/\(user.uid)").observeSingleEvent(of: .value) { (snapshot) in
            let isLiked = snapshot.exists()
            let paths = [
            "/posts/\(postID)/likes/\(user.uid)",
                "/user-posts/\(user.uid)/\(postID)/likes/\(user.uid)",
                "users/\(user.uid)/likes/\(postID)"
            ]
            if isLiked {
                for path in paths {
                    self.databaseRef.child(path).removeValue()
                }
            }
            else {
                var childUpdates:[String:Any] = [:]
                for path in paths {
                    childUpdates[path] = true
                }
                self.databaseRef.updateChildValues(childUpdates)
            }
        }
    }
    
    func getLikesForPost(post:BSPost, completion:@escaping ((_ likesCount:Int) -> Void) ) {
        if let postID = post.id, postID.isEmpty == false {
            self.databaseRef.child("posts").child(postID).child("likes").observe(DataEventType.value, with: { (data) in
                completion(Int(data.childrenCount))
            })
        }
    }
}
