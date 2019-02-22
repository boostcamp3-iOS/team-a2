//
//  DateFormatter+Default.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

extension DateFormatter {
    /**
     공통적으로 사용할 DateFormatter
     
     TimeZone과 Locale이 설정되어 있다.
     */
    static let defaultInstance: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
}
