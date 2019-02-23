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
    
    /// 최근 저널인 애들만 불러오는 Predicate
    var currentJournalPredicate: NSPredicate {
        if isDefaultJournal(uuid: currentJournal.journalId) {
            return NSPredicate(format: "journal != nil")
        } else {
            return NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal])
        }
    }
    
    // MARK: - Methods
    
    
    /**
     CoreDataManger Insttance를 생성합니다.
     
     defaultJournalUUID가 nil인지 여부를 통해 최초 실행인지 아닌지를 판단합니다.
     최초 실행일 경우 defaultJournal '모든 항목'을 생성합니다.
     모든 항목은 모든 저널을 보여주게 하는 역할을 하며 실제로 Entry가 저장되는 역할을 하지 않습니다.
     이후 추가로 '저널'을 생성합니다.
     이때 만들어진 저널이 최근 저널로 지정됩니다. 사용자가 저널을 생성하지 않고 Entry를 작성할 경우 이 저널에 속하게 됩니다.
     */
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
    
    /**
     사용자가 선택한 최근 저널을 변경합니다.
     
     UserDefaults에 저장된 최근 저널 id 값을 변경하고 DidChangedEntriesFilterNotification Noti를 push 합니다.
     
     - Parameters:
        - journal: 변경 될 저널
     */
    func changeCurrentJournal(to journal: Journal) {
        OneDayDefaults.currentJournalUUID = journal.journalId.uuidString
        NotificationCenter.default.post(name: CoreDataManager.DidChangedEntriesFilterNotification, object: nil)
    }
    
    func isDefaultJournal(uuid: UUID) -> Bool {
        return uuid == defaultJournalUUID
    }

    /**
     Core Data 변경사항을 저장합니다.
     
     저장에 성공했을 경우 DidChangedCoreDataNotification Noti를 push하고 successHandler 를 호출합니다.
     
     - Parameters:
        - successHandler: 저장에 성공했을 때의 동작을 담은 클로저
        - errorHandler: 저장에 실패했을 때의 동작을 담은 클로저
     */
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
    
    var currentJournalEntries: [Entry] {
        do {
            return try coreDataStack.managedContext.fetch(currentJournalEntriesRequest)
        } catch {
            fatalError("Couldn't get currentJournalEntries")
        }
    }
    
    // 최신 저널의 Entry들을 불러오는 NSFetchRequest
    private var currentJournalEntriesRequest: NSFetchRequest<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = currentJournalPredicate
        // 데이트 최신인 순으로 정렬하기
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        return fetchRequest
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
    
    func remove(entry: Entry) {
        managedContext.delete(entry)
        save()
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
