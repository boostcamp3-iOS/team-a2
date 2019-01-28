//
//  Entry+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData

extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var entryId: UUID?
    @NSManaged public var favorite: Bool
    @NSManaged public var title: String?
    @NSManaged public var updatedDate: NSDate?
    @NSManaged public var contents: NSSet?
    @NSManaged public var device: Device?
    @NSManaged public var journal: Journal?
    @NSManaged public var location: Location?
    @NSManaged public var weather: Weather?

}

// MARK: Generated accessors for contents
extension Entry {

    @objc(addContentsObject:)
    @NSManaged public func addToContents(_ value: Content)

    @objc(removeContentsObject:)
    @NSManaged public func removeFromContents(_ value: Content)

    @objc(addContents:)
    @NSManaged public func addToContents(_ values: NSSet)

    @objc(removeContents:)
    @NSManaged public func removeFromContents(_ values: NSSet)

}
