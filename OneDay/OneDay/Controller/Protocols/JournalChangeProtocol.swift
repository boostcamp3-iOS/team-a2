//
//  JournalChangeProtocol.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 19..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

protocol JournalChangeDelegate: class {
    func changeJournal(to journal: Journal)
}
