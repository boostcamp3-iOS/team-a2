//
//  Tag+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 13/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var title: String?
    @NSManaged public var entry: Entry?

}
