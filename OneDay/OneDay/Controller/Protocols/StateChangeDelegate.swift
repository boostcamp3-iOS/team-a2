//
//  SendDataProtocol.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 15..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

/// 뷰의 상태 변화를 요청하기 위한 Delegate
protocol StateChangeDelegate: class {
    func changeState()
}
