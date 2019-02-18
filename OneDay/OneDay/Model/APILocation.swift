//
//  APILocation.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 14..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

struct APILocation: Codable {
    let results: [Results]
}

struct Results: Codable {
    let fullAddress: String
    
    enum CodingKeys: String, CodingKey {
        case fullAddress = "formatted_address"
    }
}
