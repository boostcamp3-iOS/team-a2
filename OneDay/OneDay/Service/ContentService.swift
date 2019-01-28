//
//  ContentService.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData

final class ContentService: CoreDataService {
    public func addContents(entry: Entry, contents: [Content]) -> NSSet {
        var index: Int16 = 0
        
        contents.forEach { data in
            if let image = data as? ImageContent {
                let content = ImageContent(context: managedObjectContext)
                content.index = index as NSNumber
                content.height = image.height
                content.width = image.width
                content.image = image.image
            } else if data is TextContent {
                let content = TextContent(context: managedObjectContext)
                content.index = index as NSNumber
            }
            index += 1
        }
        coreDataStack.saveContext(managedObjectContext)
        return NSSet(array: contents)
    }
    
    public func getContents(_ entryId: UUID) -> [Content] {
        let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Content.entry.entryId), entryId])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Content.index), ascending: true)]
        
        do {
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
}
