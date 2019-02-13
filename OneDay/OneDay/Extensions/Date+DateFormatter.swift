//
//  Date+DateFormatter.swift
//  OneDay
//
//  Created by juhee on 13/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

extension Date {
    
    var day: String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        return dateFormatter.string(from: self)
    }
    
    var monthAndYear: String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        return dateFormatter.string(from: self)
    }
}
