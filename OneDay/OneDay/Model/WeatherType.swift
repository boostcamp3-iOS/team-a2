//
//  WeatherType.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

public enum WeatherType: String {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain = "rain"
    case snow = "snow"
    case sleet = "sleet"
    case wind = "wind"
    case fog = "fog"
    case cloudy = "cloudy"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case unknown = ""
    
    var summary: String {
        switch self {
        case .clearDay: return "맑음"
        case .clearNight: return "맑은 저녁"
        case .rain: return "비"
        case .snow: return "눈"
        case .sleet: return "진눈깨비"
        case .wind: return "강풍"
        case .fog: return "안개"
        case .cloudy: return "흐림"
        case .partlyCloudyDay: return "약간 흐림"
        case .partlyCloudyNight: return "흐린 저녁"
        case .unknown: return ""
        }
    }
}
