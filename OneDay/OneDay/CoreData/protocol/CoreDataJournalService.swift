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
    
    func journal(_ title: String) -> Journal
    func journal(_ title: String, index: NSNumber) -> Journal
    func journal(id: UUID) -> Journal
    func journals() -> [Journal]
    func journal(remove journal: Journal)
}
