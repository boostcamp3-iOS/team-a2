//
//  FilterType.swift
//  OneDay
//
//  Created by juhee on 21/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

/// 필터할 수 있는 타입을 enum 추상화
enum FilterType: Hashable, CaseIterable {
    case favorite
    case location
    case weather
    case device
    
    /// 필터 타이틀
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
    
    /// 왼쪽 아이콘 이미지
    var iconImage: UIImage? {
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
    
    /// 클릭 시 결과화면으로 한번 더 들어가야 하는지, 바로 모아보기로 엔트리 목록을 보여줄지 여부
    var isOneDepth: Bool {
        switch self {
        case .favorite:
            return true
        default:
            return false
        }
    }
    
    /// 필터링 됐을 때의 결과물. favorite은 바로 Entry Array가 넘어오고 나머지는 각각의 Model Array가 넘어온다.
    var data: [Filterable] {
        switch self {
        case .favorite:
            return CoreDataManager.shared.filter(by: [.currentJournal, .favorite])
        case .location:
            return CoreDataManager.shared.items(type: Location.self)
        case .weather:
            return CoreDataManager.shared.weathersGroupByType()
        case .device:
            return CoreDataManager.shared.items(type: Device.self)
        }
    }
}
