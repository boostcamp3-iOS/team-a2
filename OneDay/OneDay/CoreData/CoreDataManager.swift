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
    private var journals: [Journal] {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest) ?? []
        } catch {
            fatalError("Couldn't get journals")
        }
    }
    private var currentJournal: Journal {
        guard let journalId = UserDefaults.standard.value(forUndefinedKey: "current_journal_id") as? UUID else {
            let defaultJournal = journal("저널", index: 0)
            UserDefaults.standard.set(defaultJournal.journalId, forKey: "current_journal_id")
            return defaultJournal
        }
        return journal(id: journalId)
    }
    
    // 모든 Entries의 개수
    var allEntriesCount: Int {
        return journals.reduce(into: 0, { result, journal in
            result += (journal.entries?.count ?? 0)
        })
    }
}

// MARK: Journal
extension CoreDataManager {
    // Create New Journal
    func journal(_ title: String, index: Int) -> Journal {
        return self.journal(title, index: index as NSNumber)
    }
    
    public func journal(_ title: String, index: NSNumber) -> Journal {
        let journal = Journal(context: coreDataStack.managedContext)
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
            results = try coreDataStack.managedContext.fetch(fetchRequest)
            guard let journal = results.first else { fatalError("Couldn't get journal with id : \(id)") }
            return journal
        } catch {
            fatalError("Couldn't get journal with id : \(id)")
        }
    }
}

// Entries
extension CoreDataManager {
    // Create New Journal
    enum EntriesFilterType {
        case all
        case photo
        case location
        case favorite
        case today
        case thisDay
    }
    
    func entries(type: EntriesFilterType = .all) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        
        switch type {
        case .photo:
            fetchRequest.predicate = NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.thumbnail)])
        case .location:
            fetchRequest.predicate = NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.location)])
        case .favorite:
            fetchRequest.predicate = NSPredicate(format: "%K", argumentArray: [#keyPath(Entry.favorite)])
        case .today:
            fetchRequest.predicate = NSPredicate(format: "%K == Date()", argumentArray: [#keyPath(Entry.date)])
        case .thisDay:
            fetchRequest.predicate = NSPredicate(format: "%K == Date()", argumentArray: [#keyPath(Entry.date)])
        case .all:
            break
        }
        
        let results: [Entry]?
        do {
            results = try coreDataStack.managedContext.fetch(fetchRequest)
            return results ?? []
        } catch {
            fatalError("Couldn't get entries")
        }
    }
}
