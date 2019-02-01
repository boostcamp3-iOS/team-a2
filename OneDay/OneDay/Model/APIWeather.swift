//
//  Weather.swift
//  OneDayProto
//
//  Created by Wongeun Song on 2019. 1. 31..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

struct APIWeather: Codable {
    
    struct Currently: Codable {
        let temperature: Double
        let icon: String
    }
    
    let currently: Currently
}
