//
//  Entry+CoreDataClass.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData

@objc(Entry)
public class Entry: NSManagedObject {
    
    func updateDate(date: Date) {
        self.date = date
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        if let month = dateComponents.month as NSNumber? {
            self.month = month
        }
        if let day = dateComponents.day as NSNumber? {
            self.day = day
        }
        if let year = dateComponents.year as NSNumber? {
            self.year = year
        }
        self.monthAndYear = "\(year) \(month)"
    }
    
    lazy var thmbnailFileName: String = "entry_thumbnail_\(entryId.uuidString)"
    
}
