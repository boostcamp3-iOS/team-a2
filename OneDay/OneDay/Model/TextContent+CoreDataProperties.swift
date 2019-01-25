//
//  TextContent+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import Foundation
import CoreData


extension TextContent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TextContent> {
        return NSFetchRequest<TextContent>(entityName: "TextContent")
    }

    @NSManaged public var content: String?

}
