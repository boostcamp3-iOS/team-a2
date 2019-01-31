//
//  CoreDataStack.swift
//  OneDayProto
//
//  Created by juhee on 30/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()

    private lazy var storeContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveContext () {
        guard managedContext.hasChanges else { return }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
