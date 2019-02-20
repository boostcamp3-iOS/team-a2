//
//  CoreDataDeviceService.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 17..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

protocol CoreDataDeviceService {
    var numbersOfDevices: Int { get }
    var devices: [Device] { get }
    func insertDevice() -> Device
}
