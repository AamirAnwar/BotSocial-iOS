//
//  CoreDataStack.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName:String
    init(modelName:String) {
        self.modelName = modelName
    }
    
    private lazy var storeContainer:NSPersistentContainer = {
       let container = NSPersistentContainer.init(name: self.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    lazy var managedContext:NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    func saveContext() {
        guard self.managedContext.hasChanges else {return}
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error)")
        }
        
        
    }
}



