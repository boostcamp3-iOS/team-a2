//
//  Entry+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData

extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var date: Date?
    @NSManaged public var entryId: UUID?
    @NSManaged public var favorite: Bool
    @NSManaged public var title: String?
    @NSManaged public var updatedDate: Date?
    @NSManaged public var contents: NSAttributedString?
    @NSManaged public var device: Device?
    @NSManaged public var journal: Journal?
    @NSManaged public var location: Location?
    @NSManaged public var weather: Weather?

}
