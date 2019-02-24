//
//  Device+CoreDataProperties.swift
//  
//
//  Created by Wongeun Song on 2019. 2. 14..
//
//

import Foundation
import CoreData

extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var deviceId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var model: String?
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension Device {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: Entry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: Entry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}
