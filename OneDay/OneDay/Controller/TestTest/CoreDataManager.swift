//
//  CoreDataManager.swift
//  OneDay
//
//  Created by juhee on 11/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

final class CoreDataManager {
    // MARK: - Properties
    static let shared = CoreDataManager()
    private var coreDataStack: CoreDataStack = CoreDataStack(modelName: "OneDay")
//    private lazy var managedContext: NSManagedObjectContext = coreDataStack.managedContext
    lazy var managedContext: NSManagedObjectContext = coreDataStack.managedContext

    init() {
        if OneDayDefaults.defaultJournalUUID == nil {
            // INITIAL
            let defaultJournal = journal("모든 항목", index: 0)
            OneDayDefaults.defaultJournalUUID = defaultJournal.journalId.uuidString
            
            let currentJournal = journal("저널", index: 1)
            OneDayDefaults.currentJournalUUID = currentJournal.journalId.uuidString
        } else {
            defualtJournalUUID = UUID(uuidString: OneDayDefaults.defaultJournalUUID!)!
        }
    }
    
    private var defualtJournalUUID: UUID!
    var currentJournal: Journal {
        guard let uuidString = OneDayDefaults.currentJournalUUID else {
            fatalError()
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            preconditionFailure("invalid uuidString : \(uuidString)")
        }
        return journal(id: uuid)
    }
    
    // 모든 Entries의 개수
    var allEntriesCount: Int {
        return entries().count
    }
    var allJournalsCount: Int {
        return journals().count
    }
    
    func changeJournal(journal: Journal) {
        OneDayDefaults.currentJournalUUID = journal.journalId.uuidString
    }
    
    func isDefaultJournal(uuid: UUID) -> Bool {
        return uuid == defualtJournalUUID
    }
    
    func save() {
        coreDataStack.saveContext()
    }
}

// MARK: Journal
extension CoreDataManager : CoreDataJournalService {
    // Create New Journal
    func journal(_ title: String) -> Journal {
        return self.journal(title, index: allJournalsCount as NSNumber)
    }
    
    public func journal(_ title: String, index: NSNumber) -> Journal {
        let journal = Journal(context: managedContext)
        journal.title = title
        journal.color = UIColor.doBlue
        journal.index = index
        journal.journalId = UUID()
        coreDataStack.saveContext()
        return journal
    }
    
    func journal(id: UUID) -> Journal {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Journal.journalId), id])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        
        let results: [Journal]
        do {
            results = try managedContext.fetch(fetchRequest)
            guard let journal = results.first else { fatalError("Couldn't get journal with id : \(id)") }
            return journal
        } catch {
            fatalError("Couldn't get journal with id : \(id)")
        }
    }
    
    func journal(remove journal: Journal) {
        managedContext.delete(journal)
        coreDataStack.saveContext()
    }
    
    func journals() -> [Journal] {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        
        do {
            let jourmals =  try coreDataStack.managedContext.fetch(fetchRequest)
            print("jourmals : \(jourmals.count)")
            return jourmals
            //            return try coreDataStack.managedContext.fetch(fetchRequest)
            
        } catch {
            fatalError("Couldn't get journals")
        }
    }
}

// Entries
extension CoreDataManager: CoreDataEntryService {
    func entry() -> Entry {
        let entry = Entry(context: managedContext)
        let today: Date = Date()
        entry.updatedDate = today
        entry.date = today
        entry.entryId = UUID()
        entry.title = "새로운 엔트리"
        entry.journal = currentJournal
        coreDataStack.saveContext()
        return entry
    }
    
    func entry(remove entry: Entry) {
        managedContext.delete(entry)
        coreDataStack.saveContext()
    }
    
    func entries(type forResultController: EntryFilter, sectionNameKeyPath: String?) -> NSFetchedResultsController<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = forResultController.filterFetchRequest(currentJournal: currentJournal)
        
        return NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: forResultController.cacheName)
    }
    
    func entries(type forData: EntryFilter = .all) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = forData.filterFetchRequest(currentJournal: currentJournal)
        
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get entries")
        }
    }
    
    func entries(keyword: String) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        let keywordPredicate = NSPredicate(format: "%K contains[c] %@", keyword)
        let journalPredicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal])
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [keywordPredicate, journalPredicate])
        
        let results: [Entry]?
        do {
            results = try coreDataStack.managedContext.fetch(fetchRequest)
            return results ?? []
        } catch {
            fatalError("Couldn't get entries")
        }
    }
    
    func entriesFetchedResult() -> NSFetchedResultsController<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal])
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.date),
            cacheName: "entries")
        return fetchedResultsController
    }
    
}

extension CoreDataManager: CoreDataWeatherService {
    func weather() -> Weather {
        let weather = Weather(context: managedContext)
        weather.weatherId = UUID.init()
        return weather
    }
}

protocol CoreDataEntryService {
    
    func entry() -> Entry
    func entry(remove entry: Entry)
    func entries(type forData: EntryFilter) -> [Entry]
    func entries(type forResultController: EntryFilter, sectionNameKeyPath: String?) -> NSFetchedResultsController<Entry>
    func entries(keyword: String) -> [Entry]
}


protocol CoreDataJournalService {
    
    func journal(_ title: String) -> Journal
    func journal(_ title: String, index: NSNumber) -> Journal
    func journal(id: UUID) -> Journal
    func journals() -> [Journal]
    func journal(remove journal: Journal)
}

class CoreDataService {
    // MARK: Properties
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    // MARK: Initializers
    public convenience init(managedObjectContext: NSManagedObjectContext) {
        self.init(managedObjectContext: managedObjectContext, coreDataStack: CoreDataStack())
    }
    
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
}




import Foundation

protocol CoreDataWeatherService {
    func weather() -> Weather
}


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
        
        print(storePath)
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


enum EntryFilter {
    case all
    case photo
    case location
    case favorite
    case today
    case thisDay
    
    var cacheName: String {
        switch self {
        case .all:
            return "all_entries"
        case .photo:
            return "photo_entries"
        case .location:
            return "location_entries"
        case .favorite:
            return "favorite_entries"
        case .today:
            return "today_entries"
        case .thisDay:
            return "thisDay_entries"
        }
    }
    
    func filterFetchRequest(currentJournal: Journal) -> NSFetchRequest<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.journal.index), ascending: true)]
        var predicateArray : [NSPredicate] = []
        
        switch self {
        case .photo:
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.thumbnail)]))
        case .location:
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.location)]))
        case .favorite:
            predicateArray.append(NSPredicate(format:"%K", argumentArray: [#keyPath(Entry.favorite)]))
        case .today:
            predicateArray.append(NSPredicate(format: "%K == Date()", argumentArray: [#keyPath(Entry.date)]))
        case .thisDay:
            predicateArray.append(NSPredicate(format: "%K == Date()", argumentArray: [#keyPath(Entry.date)]))
        case .all:
            return fetchRequest
        }
        predicateArray.append(NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal]))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        return fetchRequest
    }
}


class OneDayDefaults {
    
    private static let defaults = UserDefaults.standard
    private static let keyDefaultJournal = "initalJournal"
    private static let keyCurrentJournal = "current_journal_uuidString"
    
    static var defaultJournalUUID: String? = defaults.string(forKey: keyDefaultJournal) {
        willSet(newValue) {
            defaults.set(newValue, forKey: keyDefaultJournal)
        }
    }
    
    static var currentJournalUUID: String? = defaults.string(forKey: keyCurrentJournal) {
        willSet(newValue) {
            defaults.set(newValue, forKey: keyCurrentJournal)
        }
    }
}
