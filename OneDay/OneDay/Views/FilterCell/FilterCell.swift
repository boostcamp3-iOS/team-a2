//
//  FilterCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class FilterCell: UITableViewCell {
    // MARK: Properties
    // Layout Components
    private let filterIcon: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "sideMenuFilter") ?? UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter"
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(filter type: FilterType, count: Int) {
        selectionStyle = .none
        filterIcon.image = type.icon
        filterLabel.text = type.title
        contentsCountLabel.text = "\(count)"
    }
}

extension FilterCell {
    private func setupCell() {
        addSubview(filterIcon)
        filterIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        filterIcon.widthAnchor.constraint(equalToConstant: 24)
        filterIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(filterLabel)
        filterLabel.leftAnchor.constraint(equalTo: filterIcon.rightAnchor, constant: 24).isActive = true
        filterLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(contentsCountLabel)
        contentsCountLabel.leftAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        contentsCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
