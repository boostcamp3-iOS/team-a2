//
//  Entry+CoreDataProperties.swift
//  OneDay
//
//  Created by 정화 on 18/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var contents: NSAttributedString?
    @NSManaged public var date: Date
    @NSManaged public var day: NSNumber
    @NSManaged public var entryId: UUID
    @NSManaged public var favorite: Bool
    @NSManaged public var month: NSNumber
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedDate: Date?
    @NSManaged public var year: NSNumber
    @NSManaged public var monthAndYear: String?
    @NSManaged public var device: Device?
    @NSManaged public var journal: Journal?
    @NSManaged public var location: Location?
    @NSManaged public var tags: NSSet?
    @NSManaged public var weather: Weather?
    
}

// MARK: Generated accessors for tags
extension Entry {
    
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
        
    }
    
    var thmbnailFileName: String {
        return "entry_thumbnail_\(entryId.uuidString)"
    }

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
