//
//  SideMenuFilterCellType.swift
//  OneDay
//
//  Created by juhee on 19/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

enum SideMenuFilterCellType: Int {
    
    case filter = 0
    case onThisDay = 1
    
    var title: String {
        switch self {
        case .filter:
            return "Filter"
        case .onThisDay:
            return "On this Day"
        }
    }
    
    var icon: String {
        switch self {
        case .filter:
            return "sideMenuFilter"
        case .onThisDay:
            return "sideMenuCalendar"
        }
    }
    
    var rowForCell: Int {
        return self.rawValue
    }
}
