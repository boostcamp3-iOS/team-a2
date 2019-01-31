//
//  CoreDataStack.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData

protocol UsesCoreDataObjects: class {
    var managedObjectContext: NSManagedObjectContext? { get set }
}

// MARK: - Core Data stack
class CoreDataStack {
    private let modelName: String
    
    // .xcdatamodel identifier
    lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext
    
    // 저장할 file URL
    var storeURL : URL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let storePath = storePaths[0] as NSString
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(
                atPath: storePath as String,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("[CoreDataStack] Error creating storePath \(storePath): \(error)")
        }
        
        let sqliteFilePath = storePath.appendingPathComponent(modelName + ".sqlite")
        return URL(fileURLWithPath: sqliteFilePath)
    }
    
    // 저장할 file URL
    // 사실 디스크립션은 옵션이에요 없어도 되요.
    lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: self.storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = false
        return description
    }()
    
    // 파일에 읽고/쓰기 담당하는 Container
    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.persistentStoreDescriptions = [self.storeDescription]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("storeDescription : \(storeDescription) Unresolved error \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Initializer
    init(modelName: String = "OneDay") {
        self.modelName = modelName
    }
    
    // 변경사항 저장
    func saveContext () {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
