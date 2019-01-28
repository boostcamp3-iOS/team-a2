//
//  Weather+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData

extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var tempature: Float
    @NSManaged public var type: Int16
    @NSManaged public var weatherId: UUID?
    @NSManaged public var entry: Entry?

}
