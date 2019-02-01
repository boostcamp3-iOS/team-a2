//
//  Weather+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var icon: String?
    @NSManaged public var tempature: Double
    @NSManaged public var summary: String?
    @NSManaged public var weatherId: UUID?
    @NSManaged public var entry: Entry?

}
