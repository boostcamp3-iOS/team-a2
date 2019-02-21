//
//  Setting.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 13..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit

///세팅 테이블에 들어갈 데이터를 바인딩 하기위해 사용
class EntrySetting {
    var title: String?
    var detail: String?
    var image: UIImage?
    var accessoryType: UITableViewCell.AccessoryType
    
    init(title: String?, detail: String?, image: UIImage?) {
        self.title = title
        self.detail = detail
        self.image = image
        accessoryType = .none
    }
}
