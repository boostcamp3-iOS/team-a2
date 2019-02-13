//
//  Setting.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 13..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit

///세팅 테이블에 들어갈 데이터를 바인딩 하기위해 사용
class Setting {
    var title: String?
    var detail: String?
    var image: UIImage?
    var hasDisclouserIndicator: Bool
    
    init(_ title: String?, _ detail: String?, _ image: UIImage?) {
        self.title = title
        self.detail = detail
        self.image = image
        hasDisclouserIndicator = false
    }
}
