//
//  SideMenuSection.swift
//  OneDay
//
//  Created by juhee on 12/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

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
        case .setting: return 1
        }
    }
    
    var heightForCell: CGFloat {
        switch self {
        case .filters:
            return 40
        default:
            return 60
        }
    }
    
    var heightForHeaderInSection: CGFloat {
        switch self {
        case .filters, .addJournal:
            return 0
        default:
            return 2
        }
    }
    
    var viewForHeaderInSection: UIView? {
        switch self {
        case .filters, .addJournal:
            return nil
        default:
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.sideMenuWidth, height: heightForHeaderInSection))
            headerView.backgroundColor = .doLight
            return headerView
        }
    }
}
