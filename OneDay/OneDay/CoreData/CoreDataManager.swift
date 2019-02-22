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
    static let DidChangedEntriesFilterNotification: Notification.Name = Notification.Name("didChangedEntriesFilterNotification")
    static let DidChangedCoreDataNotification: Notification.Name = Notification.Name("didChangedCoreDataNotification")
    
    private var defaultJournalUUID: UUID!
    private var coreDataStack: CoreDataStack = CoreDataStack(modelName: "OneDay")
    private lazy var managedContext: NSManagedObjectContext = coreDataStack.managedContext
    
    private var entryPredicates: [NSPredicate] = [] {
        didSet {
            NotificationCenter.default.post(name: CoreDataManager.DidChangedEntriesFilterNotification, object: nil)
        }
    }
    
    // 최근 저널인 애들만 불러오는 거
    var currentJournalPredicate: NSPredicate {
        if isDefaultJournal(uuid: currentJournal.journalId) {
            return NSPredicate(format: "journal != nil")
        } else {
            return NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal])
        }
    }
    
    // INITIAL
    private init() {
        if OneDayDefaults.defaultJournalUUID == nil {
            let defaultJournal = insertJournal("모든 항목", index: 0)
            OneDayDefaults.defaultJournalUUID = defaultJournal.journalId.uuidString
            
            let currentJournal = insertJournal("저널", index: 1)

            OneDayDefaults.currentJournalUUID = currentJournal.journalId.uuidString
        } else {
            defaultJournalUUID = UUID(uuidString: OneDayDefaults.defaultJournalUUID!)!
        }
    }
    
    func changeCurrentJournal(to journal: Journal) {
        OneDayDefaults.currentJournalUUID = journal.journalId.uuidString
        NotificationCenter.default.post(name: CoreDataManager.DidChangedEntriesFilterNotification, object: nil)
    }
    
    func isDefaultJournal(uuid: UUID) -> Bool {
        return uuid == defaultJournalUUID
    }

    func save(successHandler: (() -> Void)? = nil, errorHandler: ((NSError) -> Void)? = nil) {
        coreDataStack.saveContext(successHandler: {
            NotificationCenter.default.post(name: CoreDataManager.DidChangedCoreDataNotification, object: nil)
            if let successHandler = successHandler {
                successHandler()
            }
        }, errorHandler: errorHandler)
    }

}

// MARK: Journal
extension CoreDataManager : CoreDataJournalService {
    
    // 저널의 수
    var numberOfJounals: Int {
        return journals.count
    }
    // 모든 저널
    var journals: [Journal] {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get journals")
        }
    }
    
    // 모든 저널 : 모든 저널 제외
    var journalsWithoutDefault: [Journal] {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "index != 0")
        
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get journals")
        }
    }
    // 최근 저널
    var currentJournal: Journal {
        guard let uuidString = OneDayDefaults.currentJournalUUID else {
            fatalError()
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            preconditionFailure("invalid uuidString : \(uuidString)")
        }
        return journal(id: uuid)
    }

    public func insertJournal(_ title: String, index: Int) -> Journal {
        let journal = Journal(context: managedContext)
        journal.title = title
        journal.color = UIColor.doBlue
        if index == Constants.automaticNextJournalIndex {
            journal.index = numberOfJounals as NSNumber
        } else {
            journal.index = index as NSNumber
        }
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
    
    func remove(journal: Journal) {
        managedContext.delete(journal)
        save()
    }
}

// Entries
extension CoreDataManager: CoreDataEntryService {

    // 모든 저널에 포함된 Entries의 개수
    var numberOfEntries: Int {
        return journals.reduce(0, { $0 + ($1.entries?.count ?? 0) })
    }
    
    // 최근 저널에 포함된 Entries의 개수
    var numberOfCurrentJournalEntries: Int {
        return currentJournalEntries.count
    }
    
    var currentJournalEntries: [Entry] {
        do {
            return try coreDataStack.managedContext.fetch(currentJournalEntriesRequest)
        } catch {
            fatalError("Couldn't get currentJournalEntries")
        }
    }
    
    // 최신 저널의 Entry들을 불러오는 NSFetchRequest
    var currentJournalEntriesRequest: NSFetchRequest<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = currentJournalPredicate
        // 데이트 최신인 순으로 정렬하기
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        return fetchRequest
    }
    
    // 최신 저널의 Entry들을 불러오는 NSFetchedResultsController : TableView 와 함께 사용하세영
    // 날짜로 section이 구분됩니다.
    var currentJournalEntriesResultsController: NSFetchedResultsController<Entry> {
        return NSFetchedResultsController(
            fetchRequest: currentJournalEntriesRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.date),
            cacheName: "currentJournalEntriesResultsController")
    }
    
    var timelineResultsController: NSFetchedResultsController<Entry> {
        return NSFetchedResultsController(
            fetchRequest: currentJournalEntriesRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.monthAndYear),
            cacheName: "timelineResultsController")
    }
  
    func insertEntry() -> Entry {
        let entry = Entry(context: managedContext)
        entry.entryId = UUID()
        entry.title = "새로운 엔트리"
        if isDefaultJournal(uuid: currentJournal.journalId) {
            guard let journal = journalsWithoutDefault.first else {
                preconditionFailure("최소 한 개 이상의 저널이 있어야 합니다.")
            }
            entry.journal = journal
        } else {
            entry.journal = currentJournal
        }
        entry.updateDate(date: Date())
        save()
        return entry
    }
    
    func filter(by filters: [EntryFilter]) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        var predicate: [NSPredicate] = []
        predicate.append(contentsOf: entryPredicates)
        filters.forEach { filter in
            predicate.append(contentsOf: filter.predicates)
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.journal.index), ascending: true),
                                        NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)]
        do {
            return try managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Failed get EntryData")
        }
    }
    
    // 키워드를 가지는 entry 검색하기
    func search(with keyword: String) -> [Entry] {
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
    
    func groupByDate() -> [Any] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: EntryFilter.currentJournal.predicates)
        fetchRequest.resultType = .dictionaryResultType
        
        fetchRequest.propertiesToFetch = ["year", "month", "day"]
        fetchRequest.propertiesToGroupBy = ["month", "day", "year"]
        
        do {
            let dateCount = try managedContext.fetch(fetchRequest)
            return dateCount
        } catch {
            fatalError("Failed get EntryData")
        }
    }
    
    func remove(entry: Entry) {
        managedContext.delete(entry)
        save()
    }
    
    // filter type 별로 검색된 FetchedResultController
    func filterdResultsController(type filter: EntryFilter, sectionNameKeyPath: String?) -> NSFetchedResultsController<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.journal.index), ascending: true)]
        var predicateArray: [NSPredicate] = filter.predicates
        predicateArray.append(contentsOf: EntryFilter.currentJournal.predicates)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        
        return NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: filter.cacheName)
    }
    
}

extension CoreDataManager: CoreDataWeatherService {
    var numbersOfWeathers: Int {
        return weathers.count
    }
    
    var weathers: [Weather] {
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get weathers")
        }
    }
    
    func insertWeather() -> Weather {
        let weather = Weather(context: managedContext)
        weather.weatherId = UUID.init()
        coreDataStack.saveContext()
        return weather
    }
}

extension CoreDataManager: CoreDataDeviceService {
    var devices: [Device] {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get entries")
        }
    }
    
    var numbersOfDevices: Int {
        return devices.count
    }
    
    func insertDevice() -> Device {
        let device = Device(context: managedContext)
        device.deviceId = UUID.init()
        coreDataStack.saveContext()
        return device
    }
}

extension CoreDataManager: CoreDataLocationService {
    var locations: [Location] {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get entries")
        }
    }
    
    var numbersOfLocations: Int {
        return locations.count
    }
    
    func insertLocation() -> Location {
        let location = Location(context: managedContext)
        location.locId = UUID.init()
        coreDataStack.saveContext()
        return location
    }
    
    func location(longitude: Double, latitude: Double, epsilon: Double = 0.000001) -> Location? {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        var predicateArray: [NSPredicate] = []
        predicateArray.append(NSPredicate(format: "longitude > %f AND longitude < %f", longitude - epsilon, longitude + epsilon))
        predicateArray.append(NSPredicate(format: "latitude > %f AND latitude < %f", latitude - epsilon, latitude + epsilon))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        let results: [Location]?
        do {
            results = try coreDataStack.managedContext.fetch(fetchRequest)
            return results?.first
        } catch {
            fatalError("Couldn't get entries")
        }
    }
    
    // location을 가지는 entries 를 불러온다. 이때 location으로 그룹핑
    func locationResultController() -> NSFetchedResultsController<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let locationPredicate = NSPredicate(format: "location != nil")
        let journalPredicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal])
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredicate, journalPredicate])

        return NSFetchedResultsController(
            fetchRequest: currentJournalEntriesRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.location),
            cacheName: "currentJournalEntriesResultsController")
    }
}
