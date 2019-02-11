//
//  Weather+CoreDataProperties.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 1..
//  Copyright © 2019년 teamA2. All rights reserved.
//
//

import Foundation
import CoreData

extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var type: String?
    @NSManaged public var tempature: Int16
    @NSManaged public var weatherId: UUID?
    @NSManaged public var entry: Entry?

}
