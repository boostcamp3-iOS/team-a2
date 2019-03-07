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
    
    /// 앱 전체에서 entry에 대한 필터링을 주고자 할 때 필터용 NSPredicate를 저장하는 property
    private var entryPredicates: [NSPredicate] = [] {
        didSet {
            NotificationCenter.default.post(name: CoreDataManager.DidChangedEntriesFilterNotification, object: nil)
        }
    }
    
    // MARK: - Methods
    
    /**
     CoreDataManger Instance를 생성합니다.
     
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
    
    /**
     주어진 journalId값이 '모든 항목'에 해당하는 값인지 판단합니다.
     
     '모든 항목'은 Entry를 저장하기 위한 저널이 아닙니다. 모든 저널을 아우르는 저널을 의미합니다.
     사용자는 '모든 항목'을 선택함으로써 모든 Entry들을 한 번에 확인할 수 있습니다.
     
     - Parameters:
     - uuid: 비교할 uuid값
     */
    func isDefaultJournal(uuid: UUID) -> Bool {
        return uuid == defaultJournalUUID
    }
}

// MARK: - Extensions

// MARK: Properties & Methods assosiated with current Journal

extension CoreDataManager {
    
    /// 최근 저널
    var currentJournal: Journal {
        guard let uuidString = OneDayDefaults.currentJournalUUID else {
            fatalError()
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            preconditionFailure("invalid uuidString : \(uuidString)")
        }
        return journal(id: uuid)
    }
    
    /// Entry.journal이 currentJournal인 데이터만 불러오는 Predicate
    var currentJournalPredicate: NSPredicate {
        if isDefaultJournal(uuid: currentJournal.journalId) {
            return NSPredicate(format: "journal != nil")
        } else {
            return NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Entry.journal), currentJournal])
        }
    }
    
    /// Entry.journal이 currentJournal인 데이터만 불러오는 NSFetchRequest
    private var currentJournalEntriesRequest: NSFetchRequest<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = currentJournalPredicate
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        return fetchRequest
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
}

extension CoreDataManager {
    func insert<T>(type: T.Type) -> T {
        var object: T?
        switch T.self {
        case is Journal.Type :
            let journal = Journal(context: managedContext)
            journal.journalId = UUID()
            journal.color = UIColor.doBlue
            object = journal as? T
        case is Entry.Type:
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
            object = entry as? T
        case is Weather.Type:
            let weather = Weather(context: managedContext)
            weather.weatherId = UUID.init()
            object = weather as? T
        case is Device.Type:
            let device = Device(context: managedContext)
            device.deviceId = UUID.init()
            object = device as? T
        case is Location.Type:
            let location = Location(context: managedContext)
            location.locId = UUID.init()
            object = location as? T
        default:
            ()
        }
        
        guard let result = object else { preconditionFailure("insert action failed") }
        save()
        return result
    }
    
    func items<T: NSFetchRequestResult>(type: T.Type) -> [T] {
        do {
            var fetchRequest: NSFetchRequest<T>!
            switch T.self {
            case is Journal.Type :
                fetchRequest = NSFetchRequest<T>(entityName: "Journal")
            case is Entry.Type:
                fetchRequest = NSFetchRequest<T>(entityName: "Entry")
            case is Weather.Type:
                fetchRequest = NSFetchRequest<T>(entityName: "Weather")
            case is Device.Type:
                fetchRequest = NSFetchRequest<T>(entityName: "Device")
            case is Location.Type:
                fetchRequest = NSFetchRequest<T>(entityName: "Location")
            default:
                ()
            }
            return try coreDataStack.managedContext.fetch(fetchRequest)
        } catch {
            fatalError("Couldn't get items")
        }
    }
    
    func numbersOfItems<T: NSFetchRequestResult>(type: T.Type) -> Int {
        return items(type: type).count
    }
    
    func remove(item: NSManagedObject) {
        managedContext.delete(item)
        save()
    }
}

// MARK: Journal

extension CoreDataManager {
    
    func insertJournal(_ title: String, index: Int) -> Journal {
        let journal: Journal = insert(type: Journal.self)
        journal.title = title
        if index == Constants.automaticNextJournalIndex {
            journal.index = numbersOfItems(type: Journal.self) as NSNumber
        } else {
            journal.index = index as NSNumber
        }
        coreDataStack.saveContext()
        return journal
    }
    
    /// 모든 저널을 제외한 저널 목록
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
}

extension CoreDataManager {

    /// 최근 저널의 엔티티들을 불러온다.
    var currentJournalEntries: [Entry] {
        guard let entries = currentJournal.entries,
            let result = Array(entries) as? [Entry] else { preconditionFailure("set -> array fail") }
        return result
    }
    
    /// timeline ViewController에서 사용되는 NSFetchedResultsController: Entry.monthAndYear로 section을 나눈다.
    var timelineResultsController: NSFetchedResultsController<Entry> {
        return NSFetchedResultsController(
            fetchRequest: currentJournalEntriesRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.monthAndYear),
            cacheName: "timelineResultsController_\(currentJournal.journalId)")
    }
    
    /**
     Entry를 필터링합니다.
     
     EntryFilter는 각각 NSPredicate Array를 가집니다.
     EntryFilter가 포함하고 있는 NSPredicate를 조합하여 하나의
     NSFetchRequest로 만들고 그 결과를 리턴합니다.
     
     - Parameters:
     - filters: EntryFilter enum 객체 Array
     
     - Returns:
     - 필터링 된 결과 Entry Array
     */
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
    
    /// 키워드를 가지는 entry 검색하기
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
}

extension CoreDataManager {
    
    /**
     날씨를 type별로 group한 결과를 계산합니다.
     
     날씨는 entry에 1:1 매칭관계이지만, 필터화면에서는 날짜의 type 별로 필터를 해야하기 때문에 날씨를 type으로 묶어서 보여주어야 합니다.
     GroupedWeather는 weather type과 count로 이루어져 있습니다. dictionary로 받아온 그룹화된 결과를 GroupedWeather array로 변환하여 넘겨줍니다.
     
     - Returns:
     Type 별로 그룹화된 날씨의 type과 그 수(count)를 담은 GroupedWeather Array
     */
    func weathersGroupByType() -> [GroupedWeather] {
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Weather")
        fetchRequest.resultType = .dictionaryResultType
        
        let countExpression: NSExpression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "type")])
        let countExpressionDesc = NSExpressionDescription()
        countExpressionDesc.name = "countEntries"
        countExpressionDesc.expression = countExpression
        countExpressionDesc.expressionResultType = .integer32AttributeType
        
        fetchRequest.propertiesToGroupBy = ["type"]
        fetchRequest.propertiesToFetch = ["type", countExpressionDesc]
        
        do {
            let dictionaryArray = try coreDataStack.managedContext.fetch(fetchRequest)
            var weatherArray: [GroupedWeather] = []
            print(dictionaryArray)
            dictionaryArray.forEach { (dictionary) in
                guard let type = dictionary["type"] as? String,
                    let count = dictionary["countEntries"] as? Int else { preconditionFailure("Expected value type is not matched") }
                weatherArray.append(GroupedWeather(type: type, count: count))
            }
            return weatherArray
        } catch {
            fatalError("Couldn't get matched location")
        }
    }
    
    /**
     device를 검색합니다.
     */
    func device(identifier: UUID) -> Device? {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        let latitudePredicat = NSPredicate(format: "deviceId = %@", identifier as CVarArg)
        fetchRequest.predicate = latitudePredicat
        let results: [Device]?
        do {
            results = try coreDataStack.managedContext.fetch(fetchRequest)
            return results?.first
        } catch {
            fatalError("Couldn't get matched location")
        }
    }
    
    /**
     주어진 위경도에 맞는 loation 객체가 있는지 검색합니다.
     
     - Parameters:
     - longitude: 경도
     - latitude: 위도
     - epsilon: 위*경도 계산에 사용될 오차 범위잆니다. 기본값은 0.000009 입니다.
     */
    func location(longitude: Double, latitude: Double, epsilon: Double = 0.000009) -> Location? {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        let longitudePredicat = NSPredicate(format: "longitude >= %f AND longitude <= %f",
                                            min(longitude - epsilon, longitude + epsilon),
                                            max(longitude - epsilon, longitude + epsilon))
        let latitudePredicat = NSPredicate(format: "latitude >= %f AND latitude <= %f",
                                           min(latitude - epsilon, latitude + epsilon),
                                           max(latitude - epsilon, latitude + epsilon))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [longitudePredicat, latitudePredicat])
        let results: [Location]?
        do {
            results = try coreDataStack.managedContext.fetch(fetchRequest)
            return results?.first
        } catch {
            fatalError("Couldn't get matched location")
        }
    }
    
    /// location을 가지는 entries 를 불러온다. 이때 location으로 그룹핑
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
