//
//  PostObject+CoreDataProperties.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//
//

import Foundation
import CoreData


extension PostObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostObject> {
        return NSFetchRequest<PostObject>(entityName: "PostObject")
    }

    @NSManaged public var id: String?
    @NSManaged public var authorID: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var authorName: String?
    @NSManaged public var caption: String?
    @NSManaged public var user: UserObject?

}
