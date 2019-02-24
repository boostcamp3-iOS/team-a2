//
//  DataStringSet.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

/**
 Date를 사용하여 day, weekday 등을 저장하는 구조체
 */
struct DateStringSet {
    let weekDay: String
    let time: String
    let full: String
    let day: String
    
    init(date input: Date?) {
        let date: Date = input ?? Date()
        
        let dateFormatter = DateFormatter.defaultInstance
        dateFormatter.locale = Locale.init(identifier: "ko")
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        full = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "a HH:mm"
        time = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "d"
        day = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "EEEE"
        weekDay = dateFormatter.string(from: date)
    }
}
