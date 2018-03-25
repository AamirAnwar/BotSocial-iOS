//
//  UserObject+CoreDataProperties.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//
//

import Foundation
import CoreData


extension UserObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserObject> {
        return NSFetchRequest<UserObject>(entityName: "UserObject")
    }

    @NSManaged public var id: String?
    @NSManaged public var displayName: String?
    @NSManaged public var posts: NSOrderedSet?

}

// MARK: Generated accessors for posts
extension UserObject {

    @objc(insertObject:inPostsAtIndex:)
    @NSManaged public func insertIntoPosts(_ value: PostObject, at idx: Int)

    @objc(removeObjectFromPostsAtIndex:)
    @NSManaged public func removeFromPosts(at idx: Int)

    @objc(insertPosts:atIndexes:)
    @NSManaged public func insertIntoPosts(_ values: [PostObject], at indexes: NSIndexSet)

    @objc(removePostsAtIndexes:)
    @NSManaged public func removeFromPosts(at indexes: NSIndexSet)

    @objc(replaceObjectInPostsAtIndex:withObject:)
    @NSManaged public func replacePosts(at idx: Int, with value: PostObject)

    @objc(replacePostsAtIndexes:withPosts:)
    @NSManaged public func replacePosts(at indexes: NSIndexSet, with values: [PostObject])

    @objc(addPostsObject:)
    @NSManaged public func addToPosts(_ value: PostObject)

    @objc(removePostsObject:)
    @NSManaged public func removeFromPosts(_ value: PostObject)

    @objc(addPosts:)
    @NSManaged public func addToPosts(_ values: NSOrderedSet)

    @objc(removePosts:)
    @NSManaged public func removeFromPosts(_ values: NSOrderedSet)

}
