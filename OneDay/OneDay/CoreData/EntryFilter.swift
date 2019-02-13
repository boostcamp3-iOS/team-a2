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
    case currentJournal
    case photo
    case location(location: Location?)
    case favorite
    case tag(tag: String)
    case today
    case thisDay
    
    var cacheName: String {
        switch self {
        case .all:
            return "all_entries"
        case .currentJournal:
            return "current_journal_entries"
        case .photo:
            return "photo_entries"
        case .location:
            return "location_entries"
        case .favorite:
            return "favorite_entries"
        case .tag:
            return "tag_entries"
        case .today:
            return "today_entries"
        case .thisDay:
            return "thisDay_entries"
        }
    }
    
    var predicates: [NSPredicate] {
        var predicateArray : [NSPredicate] = []

        switch self {
        case .all:
            return predicateArray
        case .currentJournal:
            let currentJournal = CoreDataManager.shared.currentJournal
            predicateArray.append(NSPredicate(format: "journal == %@", currentJournal))
        case .photo:
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.thumbnail)]))
        case .location(let location):
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.location)]))
            if let location = location {
                predicateArray.append(NSPredicate(format: "%K == %@", [#keyPath(Entry.location.longitude)], location.longitude))
                predicateArray.append(NSPredicate(format: "%K == %@", [#keyPath(Entry.location.latitude)], location.latitude))
            }
        case .favorite:
            predicateArray.append(NSPredicate(format:"%K", argumentArray: [#keyPath(Entry.favorite)]))
        case .tag:
            predicateArray.append(NSPredicate(format:"%K", argumentArray: [#keyPath(Entry.tags)]))
        case .today:
            predicateArray.append(NSPredicate(format: "%K == Date()", argumentArray: [#keyPath(Entry.date)]))
        case .thisDay:
            var dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
            if let month = dateComponents.month {
                predicateArray.append(NSPredicate(format: "%K == %@", [#keyPath(Entry.dateComponent.month)], month))
            }
            if let day = dateComponents.day {
                predicateArray.append(NSPredicate(format: "%K == %@", [#keyPath(Entry.dateComponent.day)], day))
            }
        }
        return predicateArray
    }
    
    func filterFetchRequest(currentJournal: Journal) -> NSFetchRequest<Entry> {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.journal.index), ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: self.predicates)
        return fetchRequest
    }
}
