//
//  SideMenuFilterType.swift
//  OneDay
//
//  Created by juhee on 19/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

enum SideMenuFilterType: Int, CaseIterable {
    
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
    
    var selectedHandler: (UIViewController) -> Void {
        switch self {
        case .filter:
            return { controller in
                let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
                guard let searchFilterViewController = storyboard.instantiateViewController(withIdentifier: "search_filter_view") as? SearchFilterViewController
                    else {
                        preconditionFailure()
                }
                controller.addFadeTransition()
                controller.present(searchFilterViewController, animated: false, completion: nil)
            }
        case .onThisDay:
            return { controller in
                let collectedEntiresViewController = CollectedEntriesViewController()
                let dateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
                collectedEntiresViewController.entriesData = CoreDataManager.shared.filter(by: [.currentJournal, .thisDay(month: dateComponent.month, day: dateComponent.day)])
                controller.present(collectedEntiresViewController, animated: true, completion: nil)
            }
        }
    }
}
