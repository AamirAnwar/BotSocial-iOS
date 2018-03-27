//
//  DBHelpers.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import CoreData
import Firebase


enum DBHelpers {
    
    static var managedContext:NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.coreDataStack.managedContext
        }
    }
    static var currentUser:User? {
        get {
            return APIService.sharedInstance.currentUser
        }
    }
    
    static func savePost(post:BSPost, completion:(() -> Void)? = nil) {
        guard let currentUser = DBHelpers.currentUser else  {completion?();return}
        do {
            let userFetch:NSFetchRequest<UserObject> = UserObject.fetchRequest()
            userFetch.predicate = NSPredicate.init(format:"%K == %@", #keyPath(UserObject.id), currentUser.uid)
            
            let results = try managedContext.fetch(userFetch)
            if results.count > 0 {
                guard let currentUserObject = results.first else {
                    return
                }
                if let savedPosts = currentUserObject.posts as? NSMutableOrderedSet {
                    let entityDesc = NSEntityDescription.entity(forEntityName: "PostObject", in: managedContext)!
                    let savedPost = PostObject.init(entity: entityDesc, insertInto: managedContext)
                    savedPost.id = post.id
                    savedPost.imageURL = post.imageURL
                    savedPost.authorName = post.authorName
                    savedPost.caption = post.caption
                    savedPost.authorID = post.authorID
                    savedPost.user = currentUserObject
                    savedPosts.add(savedPost)
                    currentUserObject.posts = savedPosts
                }
                
                try managedContext.save()
                completion?()
            }
        }
        catch let error as NSError {
            print("Fetch error \(error)")
            completion?()
        }
        
    }
    
    
    static func isPostSaved(postID:String, completion:@escaping (_ saved:Bool) -> Void) {
        guard let currentUser = APIService.sharedInstance.currentUser else {return}
        let postsFetch:NSFetchRequest<PostObject> = PostObject.fetchRequest()
        postsFetch.predicate = NSPredicate.init(format:"%K == %@", #keyPath(PostObject.user.id), currentUser.uid)
        let asyncFetch:NSAsynchronousFetchRequest<PostObject> = NSAsynchronousFetchRequest<PostObject>.init(fetchRequest: postsFetch) {(result) in
            if let finalResult = result.finalResult {
                for post in finalResult {
                    if post.id == postID {
                        // Yes it's saved!
                        completion(true)
                    }
                }
            }
        }
        do {
            try managedContext.execute(asyncFetch)
        }
        catch let error as NSError {
            print("Fetch Error! \(error)")
            completion(false)
            return
        }
        completion(false)
    }
}

