//
//  EntryService.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

final class EntryService : CoreDataService {
    public func addEntry(_ title: String, contents: [Content]) -> Entry {
        let entry = Entry(context: managedObjectContext)
        let today: NSDate = Date() as NSDate
        entry.updatedDate = today
        entry.date = today
        entry.entryId = UUID()
        let contentService = ContentService.init(managedObjectContext: managedObjectContext, coreDataStack: coreDataStack)
        let contentSet = contentService.addContents(entry: entry, contents: contents)
        entry.contents = contentSet
        coreDataStack.saveContext(managedObjectContext)
        return entry
    }
    
    public func getEntries(_ journalIndex: Int16) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Entry.journal.index), journalIndex])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)]
        
        do {
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    public func getEntries(_ journalIndex: Int16, date : Date) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Entry.date), date])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)]
        
        do {
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    public func getEntry(_ entryId: UUID) -> Entry? {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Entry.entryId), entryId])
        let results: [Entry]?
        do {
            results = try managedObjectContext.fetch(fetchRequest)
        } catch {
            return nil
        }
        return results?.first
    }
    
    public func deleteEntry(entryId: UUID) {
        guard let entry = getEntry(entryId) else { return }
        managedObjectContext.delete(entry)
        coreDataStack.saveContext(managedObjectContext)
    }
}
