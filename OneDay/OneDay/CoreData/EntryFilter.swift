//
//  EntryFilter.swift
//  OneDay
//
//  Created by juhee on 12/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData

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
