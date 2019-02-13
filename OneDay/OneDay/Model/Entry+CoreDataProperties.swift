//
//  Entry+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 13/02/2019.
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
    @NSManaged public var date: Date?
    @NSManaged public var entryId: UUID?
    @NSManaged public var favorite: Bool
    @NSManaged public var thumbnail: URL?
    @NSManaged public var title: String?
    @NSManaged public var updatedDate: Date?
    @NSManaged public var dateComponent: DateComponents?
    @NSManaged public var device: Device?
    @NSManaged public var journal: Journal?
    @NSManaged public var location: Location?
    @NSManaged public var tags: NSSet?
    @NSManaged public var weather: Weather?

}

// MARK: Generated accessors for tags
extension Entry {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
