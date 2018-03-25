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
    
    var currentUser:User? {
        get {
            return Auth.auth().currentUser
        }
    }
    public var isLoggedIn:Bool {
        get {
            return Auth.auth().currentUser != nil
        }
    }
    
    func getUserPosts(completion:@escaping ((_ post:BSPost?) -> Void)) {
        guard let user = self.currentUser else {return}
        self.databaseRef.child("user-posts").child("\(user.uid)").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() == false {
                completion(nil)
            }
            
            self.databaseRef.child("user-posts").child("\(user.uid)").queryLimited(toLast: 30).observe(DataEventType.childAdded, with: { (snapshot) in
                guard let value = snapshot.value as? [String:AnyObject] else {completion(nil);return}
                let post = BSPost.initWith(postID: snapshot.key, dict: value)
                completion(post)
            })

        }
        
    }
    
    
    func getPostsWith(userID:String, completion:@escaping ((_ post:BSPost?) -> Void)) {
        guard userID.isEmpty == false else {return}
        self.databaseRef.child("user-posts").child("\(userID)").queryLimited(toLast: 30).observe(DataEventType.childAdded, with: { (snapshot) in
            guard let value = snapshot.value as? [String:AnyObject] else {completion(nil);return}
            let post = BSPost.initWith(postID: snapshot.key, dict: value)
            completion(post)
        })
    }
    
    func getRecentPosts(completion:@escaping ((_ posts:BSPost?) -> Void)) {
        guard let _ = self.currentUser else {return}
        self.databaseRef.child("posts").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() == false {
                completion(nil)
            }
            self.databaseRef.child("posts").queryLimited(toLast: 30).observe(DataEventType.childAdded, with: { (snapshot) in
                guard let dict = snapshot.value as? [String:AnyObject] else {completion(nil);return}
                let post = BSPost.initWith(postID: snapshot.key, dict: dict)
                completion(post)
            })

        }
    }
    
    func getPostWith(postID:String, completion:@escaping ((_ posts:BSPost?) -> Void)) {
        self.databaseRef.child("posts").child(postID).observeSingleEvent(of: .value) { (snapshot) in
            guard let postDict = snapshot.value as? [String:AnyObject] else {completion(nil);return}
            let post = BSPost.initWith(postID: snapshot.key, dict: postDict)
            completion(post)
            
        }
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
    
    func updateUserDetails(user:User) {
        guard let name = user.displayName else {return}
        self.databaseRef.child("users").child(user.uid).updateChildValues(["display_name":name])
    }
    
    func getUserWith(userID:String,  completion:@escaping(_ user:BSUser?)->Void) {
        guard userID.isEmpty == false else {completion(nil);return}
        self.databaseRef.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String:AnyObject] {
                let userObject = BSUser.initWith(userID: userID, dict: value)
                completion(userObject)
            }
        }
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
    
    func isPostLiked(post:BSPost, completion:@escaping ((_ isLiked:Bool) -> Void) ) {
        guard let user = self.currentUser, let postID = post.id else {return}
        self.databaseRef.child("/posts/\(postID)/likes/\(user.uid)").observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func likePost(post:BSPost) {
        guard let user = self.currentUser, let postID = post.id else {return}
        
        self.databaseRef.child("/posts/\(postID)/likes/\(user.uid)").observeSingleEvent(of: .value) { (snapshot) in
            guard user.uid.isEmpty == false, let authorID = post.authorID else {return}
            let isLiked = snapshot.exists()
            
            let paths = [
                "/posts/\(postID)/likes/\(user.uid)",
                "/user-posts/\(authorID)/\(postID)/likes/\(user.uid)",
                "users/\(user.uid)/likes/\(postID)"
            ]
            if isLiked {
                for path in paths {
                    self.databaseRef.child(path).removeValue()
                }
                if let postAuthorID = post.authorID {
                    self.databaseRef.child("users").child("\(postAuthorID)").child("notifications").child("\(user.uid)_\(postID)_like").removeValue()
                }
            }
            else {
                var childUpdates:[String:Any] = [:]
                for path in paths {
                    childUpdates[path] = true
                }
                self.databaseRef.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                    if let username = user.displayName, let postAuthorID = post.authorID {
                        let notification = [
                            "author_name": username,
                            "text":"liked your post",
                            "user_id": user.uid,
                            "post_id": postID
                        ]
                        let newNotificationChild = self.databaseRef.child("users").child("\(postAuthorID)").child("notifications").childByAutoId()
                        newNotificationChild.setValue(notification)
                    }
                })
            }
        }
    }
    
    func getNotifications(completion:@escaping ((_ notification:BSNotification?, _ handle:UInt) -> Void) ) {
        guard let user = self.currentUser else {completion(nil, 0);return}
        self.databaseRef.child("users").child("\(user.uid)").child("notifications").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() == false{
                completion(nil, 0)
            }
            var handleRef:UInt = 0
            handleRef = self.databaseRef.child("users").child("\(user.uid)").child("notifications").queryLimited(toLast: 50).observe(.childAdded) { (snapshot) in
                if let value = snapshot.value as? [String:AnyObject] {
                    let notif = BSNotification.initWith(notifID:snapshot.key, notifDict:value)
                    completion(notif, handleRef)
                }
                else {
                    completion(nil, 0)
                }
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
    
    func getCommentCountForPost(post:BSPost, completion:@escaping ((_ commentCount:Int) -> Void) ) {
        if let postID = post.id, postID.isEmpty == false {
            self.databaseRef.child("posts").child(postID).child("comments").observe(DataEventType.value, with: { (data) in
                completion(Int(data.childrenCount))
            })
        }
    }
    
    func commentOnPostWith(post:BSPost, comment:String, completion:@escaping (() -> Void)) {
        guard let user = self.currentUser, let postID = post.id else {
            completion()
            return
        }
        let commentKey = self.databaseRef.child("comments").childByAutoId().key
        let commentPayload = ["author_id": user.uid,
                       "author_name": user.displayName!,
                       "text": comment,
                       ]
        let childUpdates:[String:Any] = ["/comments/\(commentKey)/": commentPayload,
                                            "/posts/\(postID)/comments/\(commentKey)/":commentPayload,
                                            "/user-posts/\(post.authorID)/\(postID)/comments/\(commentKey)/":commentPayload]
        self.databaseRef.updateChildValues(childUpdates)
        completion()
        
    }
    
    func getCommentsForPostWith(postID:String, completion:@escaping ((_ comment:BSComment) -> Void)) {
        guard postID.isEmpty == false else {return}
        self.databaseRef.child("posts").child(postID).child("comments").observe(DataEventType.childAdded, with: { (snapshot) in
            guard let commentDict = snapshot.value as? [String:AnyObject] else {return}
                let comment = BSComment.initWith(commentID: snapshot.key, dict: commentDict)
                completion(comment)
        })
        
    }
    
    func cancelHandle(_ handle:UInt?) {
        if let handle = handle {
            self.databaseRef.removeObserver(withHandle: handle)
        }
    }
    
    func sendMessageTo(receiver:BSUser, message:String ,completion:@escaping ((_ message:BSMessage?) -> Void)) {
        
        guard let user = self.currentUser,let receiverID = receiver.id, receiverID.isEmpty == false && message.isEmpty == false, let senderName = user.displayName else {
            completion(nil)
            return
        }
        self.openChannel(sender: user, receiver: receiver) { (chatID) in
            self.uploadMessage(receiverID: receiverID,
                               message: message,
                               userID: user.uid,
                               senderName: senderName,
                               chatID: chatID,
                               completion: completion)
        }
    }
    
    private func openChannel(sender:User,
                             receiver:BSUser,
                             completion:@escaping (_ chatID:String) -> Void) {
        
        guard let receiverID = receiver.id else {completion("");return}
        let senderID = sender.uid
        let senderRef = self.databaseRef.child("user_chats").child(senderID).child(receiverID)
        // Check Sender
        senderRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let senderChatKey = snapshot.key
                // Check the receiver as well
                let receiverRef = self.databaseRef.child("user_chats").child(receiverID).child(senderID)
                receiverRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        // Good to go! Get the chat ID from either one of them
                        if let value = snapshot.value as? [String:AnyObject] {
                            if let chatID = value.keys.first {
                                completion(chatID)
                            }
                        }
                        
                    }
                    else {
                        // Create entry on receivers side
                        // Get chat key from the sender and give it to the receiver
                        if let value = snapshot.value as? [String:AnyObject] {
                            if let chatID = value.keys.first {
                                // Got the Chat ID!
                                let chatMetadata:[String:Dictionary<String,String>] = ["receiver":[
                                    // TODO FIX THIS
                                    kProfilePictureURLKey:receiver.profilePictureURL,
                                    kDisplayNameKey:sender.displayName!
                                    ]]
                                receiverRef.child(chatID).setValue(chatMetadata, withCompletionBlock: { (error, ref) in
                                    // Sender and Receiver both have keys now!
                                    // Good to go!
                                    completion(snapshot.key)
                                })
                            }
                        }
                    }
                }
            }
            else {
                // Sender doesn't have a key to his name
                
                // Check Receiver for key
                let receiverRef = self.databaseRef.child("user_chats").child(receiverID).child(senderID)
                receiverRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        // If a key exists with the receiver then give it to the sender
                        let chatMetadata:[String:Dictionary<String,String>] = ["receiver":[
                            kProfilePictureURLKey:receiver.profilePictureURL,
                            kDisplayNameKey:receiver.displayName
                            ]]
                        
                        // Get chat key from receiver
                        if let value = snapshot.value as? [String:AnyObject] {
                            if let chatID = value.keys.first {
                                // Got the Chat ID!
                                senderRef.child(chatID).setValue(chatMetadata, withCompletionBlock: { (error, ref) in
                                    // Sender and Receiver both have keys now!
                                    // Good to go!
                                    completion(snapshot.key)
                                })
                            }
                        }
                        
                    }
                    else {
                        // Neither the sender nor the receiver have keys
                        let newChatkey = senderRef.childByAutoId().key
                        
                        let senderMetadata:[String:Dictionary<String,String>] = ["receiver":[
                            kProfilePictureURLKey:receiver.profilePictureURL,
                            kDisplayNameKey:sender.displayName!
                            ]]
                        
                        let receiverMetadata:[String:Dictionary<String,String>] = ["receiver":[
                            kProfilePictureURLKey:receiver.profilePictureURL,
                            kDisplayNameKey:receiver.displayName
                            ]]
                        
                        let childUpdates = ["/user_chats/\(senderID)/\(receiverID)/\(newChatkey)": receiverMetadata,
                                            "/user_chats/\(receiverID)/\(senderID)/\(newChatkey)": senderMetadata]
                        self.databaseRef.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                            completion(newChatkey)
                        })
                    }
                }
                
            }
        }
        
    }
    
    private func uploadMessage(receiverID:String, message:String, userID:String, senderName:String, chatID:String, completion:@escaping ((_ message:BSMessage?) -> Void)) {
        let message:[String:String] = ["text":message,
                                       "sender_id":userID,
                                       "chat_id":chatID,
                                       "sender_name":senderName]
        let ref = self.databaseRef.child("chats").child(chatID).child("messages").childByAutoId()
        ref.setValue(message) { (error, ref) in
            if error == nil {
                completion(BSMessage.initWith(id: ref.key, dict: message as [String:AnyObject]))
            }
            else {
                completion(nil)
            }
        }
    }
    
    func getMessagesWith(senderID:String, receiverID:String, completion:@escaping ( (_ message:BSMessage?) -> Void)) {
        self.databaseRef.child("user_chats").child(senderID).child(receiverID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String:AnyObject] {
                    if let chatID = value.keys.first {
                        self.databaseRef.child("chats").child(chatID).child("messages").queryLimited(toLast: 25).observe(.childAdded, with: { (snapshot) in
                            if let value = snapshot.value as? [String:AnyObject] {
                                let message = BSMessage.initWith(id: snapshot.key, dict: value)
                                completion(message)
                            }
                        })
                    }
                }
            }
            else {
                self.databaseRef.child("user_chats").child(receiverID).child(senderID).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        if let value = snapshot.value as? [String:AnyObject] {
                            if let chatID = value.keys.first {
                                self.databaseRef.child("chats").child(chatID).child("messages").queryLimited(toLast: 25).observe(.childAdded, with: { (snapshot) in
                                    if let value = snapshot.value as? [String:AnyObject] {
                                        let message = BSMessage.initWith(id: snapshot.key, dict: value)
                                        completion(message)
                                    }
                                })
                                
                            }
                            
                        }
                    }
                    else {
                        completion(nil)
                    }
                }
                
            }
        }
    }
    
    func isUserTyping(senderID:String, receiverID:String, completion:@escaping ( (_ ref:DatabaseReference?) -> Void)) {
        guard let _ = self.currentUser else {completion(nil);return}
        self.databaseRef.child("user_chats").child(senderID).child(receiverID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let ref = self.databaseRef.child("chats").child(snapshot.key).child("typing_indicator").child(receiverID)
                ref.onDisconnectRemoveValue()
                completion(self.databaseRef.child("chats").child(snapshot.key).child("typing_indicator"))
            }
            else {
                self.databaseRef.child("user_chats").child(receiverID).child(senderID).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() {
                        let ref = self.databaseRef.child("chats").child(snapshot.key).child("typing_indicator").child(receiverID)
                        ref.onDisconnectRemoveValue()
                        completion(self.databaseRef.child("chats").child(snapshot.key).child("typing_indicator"))
                    }
                    else {
                        completion(nil)
                    }
                }
                
            }
        }
        
    }
    
    func getUserChats(completion:@escaping (_ chat:BSChatInstance?) -> Void) {
        guard let currentUser = self.currentUser else {return}
        self.databaseRef.child("user_chats").child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.databaseRef.child("user_chats").child(currentUser.uid).observe(.childAdded) { (snapshot) in
                    var chat:BSChatInstance? = nil
                    if let value = snapshot.value as? [String:AnyObject] {
                        print("Checking chats for ID \(currentUser.uid)")
                        print(value)
                        let receiverID = snapshot.key
                        if let chatID = value.keys.first {
                            if let chatInfoDict = value[chatID] as? [String:AnyObject]{
                                if let receiverInfo = chatInfoDict["receiver"] as? [String:AnyObject] {
                                    chat =  BSChatInstance.initWith(senderID: currentUser.uid, receiverID:receiverID,receverInfo: receiverInfo)
                                }
                                
                            }
                        }
                        
                    }
                    completion(chat)
                }
            }
            else {
                completion(nil)
            }
        }

    }
    
}
