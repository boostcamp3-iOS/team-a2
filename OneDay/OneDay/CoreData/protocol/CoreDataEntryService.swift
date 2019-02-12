//
//  CoreDataEntryService.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

protocol CoreDataEntryService {
    
    func entry() -> Entry
    func entry(remove entry: Entry)
    func entries(type forData: EntryFilter) -> [Entry]
    func entries(type forResultController: EntryFilter, sectionNameKeyPath: String?) -> NSFetchedResultsController<Entry>
    func entries(keyword: String) -> [Entry]
}
