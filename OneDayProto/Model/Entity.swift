//
//  Entity.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

struct Entry {
    let id: Int
    var contents: [Content] = []
    var updatedDate: Date
    var date: Date
    var isFavorite: Bool
    var journal: Journal
    var location: Location
    var tags: [String]
    var deviceId: String
}

struct Location {
    let latitude: Double
    let longitude: Double
}

struct Weather {
    let tempture: Double
    let type: WeatherType
    
    enum WeatherType : String {
        case clearDay = "clear-day"
        case clearNight = "clear-night"
        case rain
        case snow
        case sleet
        case wind
        case fog
        case cloudy
        case partlyCloudyDay = "partly-cloudy-day"
        case partlyCloudyNight = "partly-cloudy-night"
    }
}

struct Content {
    let index: Int
    let contentType: ContentType
    let content: String
    
    enum ContentType {
        case text
        case photo
    }
    
}

struct Journal {
    let id: Int
    var title: String
    var index: Int
    var entryCount: Int
    var entries: [Entry]
}

struct User {
    let appleId: String
    let isSync: Bool
}

struct Reminder {
    let title: String
    let time: Timer
    let message: String
    let tags: String
}
