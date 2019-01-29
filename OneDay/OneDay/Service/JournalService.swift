//
//  JournalService.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

final class JournalService : CoreDataService {
    public func journal(_ title: String, index: Int) -> Journal {
        return self.journal(title, index: index as NSNumber)
    }
    
    public func journal(_ title: String, index: NSNumber) -> Journal {
        let journal = Journal(context: managedObjectContext)
        journal.title = title
        journal.color = UIColor.doBlue
        journal.index = index
        journal.journalId = UUID()
        coreDataStack.saveContext(managedObjectContext)
        return journal
    }
    
    public func journal(_ journalId: NSNumber) -> Journal? {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Journal.journalId), journalId])
        let results: [Journal]?
        do {
            results = try managedObjectContext.fetch(fetchRequest)
        } catch {
            return nil
        }
        return results?.first
    }
    
    public func journals() -> [Journal] {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)]
        
        do {
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    public func journal(remove journalId: NSNumber) {
        guard let campSite = journal(journalId) else { return }
        managedObjectContext.delete(campSite)
        coreDataStack.saveContext(managedObjectContext)
    }
}
