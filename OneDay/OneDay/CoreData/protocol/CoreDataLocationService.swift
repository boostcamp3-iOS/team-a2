//
//  CoreDataLocationService.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 17..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

protocol CoreDataLocationService {
    var numbersOfLocations: Int { get }
    var locations: [Location] { get }
    func insertLocation() -> Location
}
