//
//  FilterType.swift
//  OneDay
//
//  Created by juhee on 21/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

enum FilterType: Hashable, CaseIterable {
    case favorite
    case location
    case weather
    case device
    
    var title: String {
        switch self {
        case .favorite:
            return "즐겨찾기"
        case .location:
            return "장소"
        case .weather:
            return "날씨"
        case .device:
            return "기기"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .favorite:
            return UIImage(named: "filterHeart")
        case .location:
            return UIImage(named: "filterPlace")
        case .weather:
            return UIImage(named: "filterWeather")
        case .device:
            return UIImage(named: "filterDevice")
        }
    }
    
    var isOneDepth: Bool {
        switch self {
        case .favorite:
            return true
        default:
            return false
        }
    }
    
    var data: [NSManagedObject] {
        switch self {
        case .favorite:
            return CoreDataManager.shared.filter(by: [.currentJournal, .favorite])
        case .location:
            return CoreDataManager.shared.locations
        case .weather:
            return CoreDataManager.shared.weathers
        case .device:
            return CoreDataManager.shared.devices
        }
    }
}
