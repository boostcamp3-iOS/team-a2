//
//  FilterResultTableViewCell.swift
//  OneDay
//
//  Created by juhee on 20/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

/// 필터링된 결과 엔트리를 보여주는 셀
class FilterResultTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func bind(type: FilterType, data: Filterable, count: Int) {
        countLabel.text = "\(count)"
        iconImageView.image = type.iconImage
        
        switch type {
        case .location:
            guard let location = data as? Location else { return }
            titleLabel.text = location.address
        case .weather:
            guard let weather = data as? GroupedWeather,
                let weatherType = WeatherType(rawValue: weather.type) else { return }
            titleLabel.text = weatherType.summary
            iconImageView.image = UIImage(named: weather.type)
        case .device:
            guard let device = data as? Device else { return }
            titleLabel.text = device.name
        case .favorite:
            ()
        }
    }
}
