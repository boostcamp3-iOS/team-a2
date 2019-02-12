//
//  SideMenuSection.swift
//  OneDay
//
//  Created by juhee on 12/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

enum SideMenuSection: Int, CaseIterable {
    
    case filters = 0
    case journals = 1
    case addJournal = 2
    case setting = 3
    
    var sectionNumber: Int {
        return self.rawValue
    }
    
    var identifier: String {
        switch self {
        case .filters: return "side_filter_cell"
        case .journals: return "side_journal_cell"
        case .addJournal: return "side_add_journal_cell"
        case .setting: return "side_setting_cell"
        }
    }
    
    var numberOfRows: Int {
        switch self {
        case .filters: return 2
        case .journals: return 0
        case .addJournal: return 1
        case .setting: return 2
        }
    }
}
