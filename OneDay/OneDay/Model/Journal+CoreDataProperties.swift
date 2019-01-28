//
//  Journal+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData
import UIKit

extension Journal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Journal> {
        return NSFetchRequest<Journal>(entityName: "Journal")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var index: NSNumber
    @NSManaged public var journalId: UUID
    @NSManaged public var title: String?
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension Journal {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: Entry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: Entry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}
