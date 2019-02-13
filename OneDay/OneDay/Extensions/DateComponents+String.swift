//
//  DateComponents+String.swift
//  OneDay
//
//  Created by juhee on 13/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

extension DateComponents {
    
    var monthAndYear: String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        guard let date = self.date else { return "" }
        return dateFormatter.string(from: date)
    }
}
