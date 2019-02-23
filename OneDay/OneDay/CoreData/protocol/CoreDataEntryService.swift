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
    
    // 최근 저널에 포함된 Entries의 개수
    var numberOfEntries: Int { get }
    
    func insertEntry() -> Entry
    func filter(by filters: [EntryFilter]) -> [Entry]
    func remove(entry: Entry)
}
