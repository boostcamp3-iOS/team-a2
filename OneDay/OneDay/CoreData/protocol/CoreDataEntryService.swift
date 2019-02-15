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
    var currentJournalEntriesResultsController: NSFetchedResultsController<Entry> {
        get
    }
    
    func insert() -> Entry
    // 키워드를 가지는 entry 검색하기
    func search(with keyword: String) -> [Entry]
    func filter(by filters: [EntryFilter]) -> [Entry]
    func filterdResultsController(type filter: EntryFilter, sectionNameKeyPath: String?) -> NSFetchedResultsController<Entry>
    func remove(entry: Entry)
}
