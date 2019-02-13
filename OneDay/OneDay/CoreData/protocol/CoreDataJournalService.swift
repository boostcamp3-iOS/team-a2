//
//  CoreDataJournalService.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

protocol CoreDataJournalService {
    
    // 저널의 수
    var numberOfJounals: Int { get }
    // 모든 저널
    var journals: [Journal] { get }
    // 최근 저널
    var currentJournal: Journal { get }
    // 최신 저널의 Entry들을 불러오는 NSFetchRequest
    var currentJournalEntriesRequest: NSFetchRequest<Entry> { get }
    // 최신 저널의 Entry들을 불러오는 NSFetchedResultsController : TableView 와 함께 사용하세영
    // 날짜로 section이 구분됩니다.
    var currentJournalEntriesResultsController: NSFetchedResultsController<Entry> { get }
    
    func insert(_ title: String, index: Int) -> Journal
    func journal(id: UUID) -> Journal
    func remove(journal: Journal)
}
