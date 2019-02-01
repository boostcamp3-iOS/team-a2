//
//  DataStringSet.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

struct DateStringSet {
    let weekDay: String
    let time: String
    let full: String
    let day: String
    
    init(date input: Date?) {
        let date: Date = input ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "ko")
        dateFormatter.timeZone = TimeZone.current
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        full = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "a HH:MM"
        time = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "d"
        day = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "EEEE"
        weekDay = dateFormatter.string(from: date)
    }
}
