//
//  FilterResultTableViewCell.swift
//  OneDay
//
//  Created by juhee on 20/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class FilterResultTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func bind(type: FilterType, data: NSManagedObject, count: Int) {
        countLabel.text = "\(count)"
        iconImageView.image = type.icon
        
        switch type {
        case .location:
            guard let location = data as? Location else { return }
            titleLabel.text = location.address
        case .weather:
            guard let weather = data as? Weather, let type = weather.type else { return }
            titleLabel.text = type
            iconImageView.image = UIImage(named: type)
        case .device:
            guard let device = data as? Device else { return }
            titleLabel.text = device.name
        case .favorite:
            ()
        }
    }

}
