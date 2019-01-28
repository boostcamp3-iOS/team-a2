//
//  Location+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var locId: UUID?
    @NSManaged public var longitude: Double
    @NSManaged public var entry: NSOrderedSet?

}

// MARK: Generated accessors for entry
extension Location {

    @objc(insertObject:inEntryAtIndex:)
    @NSManaged public func insertIntoEntry(_ value: Entry, at idx: Int)

    @objc(removeObjectFromEntryAtIndex:)
    @NSManaged public func removeFromEntry(at idx: Int)

    @objc(insertEntry:atIndexes:)
    @NSManaged public func insertIntoEntry(_ values: [Entry], at indexes: NSIndexSet)

    @objc(removeEntryAtIndexes:)
    @NSManaged public func removeFromEntry(at indexes: NSIndexSet)

    @objc(replaceObjectInEntryAtIndex:withObject:)
    @NSManaged public func replaceEntry(at idx: Int, with value: Entry)

    @objc(replaceEntryAtIndexes:withEntry:)
    @NSManaged public func replaceEntry(at indexes: NSIndexSet, with values: [Entry])

    @objc(addEntryObject:)
    @NSManaged public func addToEntry(_ value: Entry)

    @objc(removeEntryObject:)
    @NSManaged public func removeFromEntry(_ value: Entry)

    @objc(addEntry:)
    @NSManaged public func addToEntry(_ values: NSOrderedSet)

    @objc(removeEntry:)
    @NSManaged public func removeFromEntry(_ values: NSOrderedSet)

}
