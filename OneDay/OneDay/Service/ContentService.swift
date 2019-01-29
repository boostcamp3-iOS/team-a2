//
//  ContentService.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import Foundation

final class ContentService: CoreDataService {
    public func content(entry: Entry, cotent data: Content) -> Content {
        var content: ImageContent!
        if let data = data as? ImageContent {
            let imageContent = ImageContent(context: managedObjectContext)
            imageContent.height = data.height
            imageContent.width = data.width
            imageContent.image = data.image
            content = imageContent
        } else if let data = data as? TextContent {
            let textContent = TextContent(context: managedObjectContext)
            textContent.content = data.content
        }
        content.index = data.index
        content.entry = entry
        coreDataStack.saveContext(managedObjectContext)
        return content
    }
    
    public func contents(entry: Entry, contents: [Content]) -> NSSet {
        var index: Int16 = 0
        
        contents.forEach { data in
            var content: ImageContent!
            if let data = data as? ImageContent {
                let imageContent = ImageContent(context: managedObjectContext)
                imageContent.height = data.height
                imageContent.width = data.width
                imageContent.image = data.image
                content = imageContent
            } else if let data = data as? TextContent {
                let textContent = TextContent(context: managedObjectContext)
                textContent.content = data.content
            }
            content.index = data.index
            content.entry = entry
            index += 1
        }
        coreDataStack.saveContext(managedObjectContext)
        return NSSet(array: contents)
    }
    
    public func contents(from entryId: UUID) -> [Content] {
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
