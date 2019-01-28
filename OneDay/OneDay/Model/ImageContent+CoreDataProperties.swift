//
//  ImageContent+CoreDataProperties.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//
//

import CoreData
import UIKit

extension ImageContent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageContent> {
        return NSFetchRequest<ImageContent>(entityName: "ImageContent")
    }

    @NSManaged public var height: Float
    @NSManaged public var image: UIImage?
    @NSManaged public var width: Float

}
