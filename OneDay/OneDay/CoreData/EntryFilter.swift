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
    case location(logitude: Double?, latitude: Double?)
    case favorite
    case tag(tag: String)
    case today
    case thisDay(month: Int?, day: Int?)
    case thisYear(year: Int)
    
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
        case .thisYear(let year):
            return "thisYear_entries_\(year)"
        }
    }
    
    var predicates: [NSPredicate] {
        var predicateArray : [NSPredicate] = []

        switch self {
        case .all:
            return []
        case .currentJournal:
            let currentJournal = CoreDataManager.shared.currentJournal
            predicateArray.append(NSPredicate(format: "journal == %@", currentJournal))
        case .photo:
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.thumbnail)]))
        case .location(let longitude, let latitude):
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.location)]))
            if let longitude = longitude, let latitude = latitude {
                predicateArray.append(NSPredicate(format: "%K == %@", [#keyPath(Entry.location.longitude)], longitude))
                predicateArray.append(NSPredicate(format: "%K == %@", [#keyPath(Entry.location.latitude)], latitude))
            }
        case .favorite:
            predicateArray.append(NSPredicate(format:"%K", argumentArray: [#keyPath(Entry.favorite)]))
        case .tag:
            predicateArray.append(NSPredicate(format:"%K", argumentArray: [#keyPath(Entry.tags)]))
        case .today:
            let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
            guard let month = dateComponents.month as NSNumber?, let day = dateComponents.day as NSNumber?, let year = dateComponents.year as NSNumber? else { return [] }
            predicateArray.append(NSPredicate(format: "year == %@", year))
            predicateArray.append(NSPredicate(format: "month == %@", month))
            predicateArray.append(NSPredicate(format: "day == %@", day))
        case .thisDay(let month, let day):
            if let month = month as NSNumber? {
                predicateArray.append(NSPredicate(format: "month == %@", month))
            }
            if let day = day as NSNumber? {
                predicateArray.append(NSPredicate(format: "day == %@", day))
            }
        case .thisYear(let year):
            if let year = year as NSNumber? {
                predicateArray.append(NSPredicate(format: "year == %@", year))
            }
        }
        return predicateArray
    }
}
