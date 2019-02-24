//
//  EntryFilter.swift
//  OneDay
//
//  Created by juhee on 12/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData

/**
    Entry 필터링 용 NSPredicate 를 담고 있는 enum 입니다.
 */
enum EntryFilter {
    case all
    case currentJournal
    case photo
    case location(address: String)
    case favorite
    case today
    case thisDay(month: Int?, day: Int?)
    case thisYear(year: Int)
    case weather(weatherType: String)
    case device(deviceId: UUID)
    
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
        case .today:
            return "today_entries"
        case .thisDay:
            return "thisDay_entries"
        case .thisYear(let year):
            return "thisYear_entries_\(year)"
        case .weather(let weatherType):
            return "weather_entries_\(weatherType)"
        case .device(let deviceId):
            return "device_entries_\(deviceId.uuidString)"
        }
    }
    
    var predicates: [NSPredicate] {
        var predicateArray : [NSPredicate] = []

        switch self {
        case .all:
            return []
        case .currentJournal:
            predicateArray.append(CoreDataManager.shared.currentJournalPredicate)
        case .photo:
            predicateArray.append(NSPredicate(format: "%K != nil", argumentArray: [#keyPath(Entry.thumbnail)]))
        case .location(let address):
            predicateArray.append(NSPredicate(format: "location.address contains %@", address))
        case .favorite:
            predicateArray.append(NSPredicate(format:"favorite == %@", NSNumber(value: true)))
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
        case .weather(let weatherType):
            predicateArray.append(NSPredicate(format: "weather.type like %@", weatherType))
        case .device(let deviceId):
            predicateArray.append(NSPredicate(format: "device.deviceId == %@", deviceId as CVarArg))
        }
        return predicateArray
    }
}
