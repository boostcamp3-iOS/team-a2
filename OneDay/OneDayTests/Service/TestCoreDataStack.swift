//
//  TestCoreDataStack.swift
//  OneDayTests
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

@testable import OneDay
import CoreData

class TestCoreDataStack: CoreDataStack {
    
    convenience override init() {
        self.init(modelName: "OneDay")
    }
    
    override init(modelName: String) {
        super.init(modelName: modelName)
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        self.storeContainer = container
    }
}
