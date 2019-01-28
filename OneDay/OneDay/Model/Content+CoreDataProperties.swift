//
//  Content+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData

extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content")
    }

    @NSManaged public var contentId: UUID?
    @NSManaged public var index: NSNumber
    @NSManaged public var type: Int16
    @NSManaged public var entry: Entry?

}
