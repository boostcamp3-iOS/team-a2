//
//  FilterSection.swift
//  OneDay
//
//  Created by 정화 on 01/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation
import UIKit

enum FilterSection {
    
    case recent
    case filter
    case keywords
    case entries

    var sectionNumber: Int {
        switch self {
        case .recent: return 0
        case .filter: return 1
        case .keywords: return 2
        case .entries: return 3
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .recent: return "Recent"
        case .filter: return "Filter"
        case .keywords: return "Keywords"
        case .entries: return "Entries"
        }
    }
    
    var identifier: String {
        switch self {
        case .recent: return "Recent"
        case .filter: return "Filter"
        case .keywords: return "Keywords"
        case .entries: return "Entries"
        }
    }
    
    var heightForSection: CGFloat {
        switch self {
        case .entries: return 70
        default: return 50
        }
    }
    
    func numberOfRows(_ isSearching: Bool = false) -> Int {
        switch self {
        case .recent:
            return 3
        case .entries:
            return 0
        case .filter:
            return !isSearching ? 6 : 0
        case .keywords:
            return isSearching ? 1 : 0
        }
    }
}
