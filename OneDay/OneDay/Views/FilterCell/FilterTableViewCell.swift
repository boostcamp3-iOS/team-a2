//
//  FilterCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

/// 필터 아이콘과 이름, 매칭되는 결과 수를 보여주는 셀
class FilterTableViewCell: UITableViewCell {
    
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
        setUpConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(filter type: FilterType, count: Int) {
        selectionStyle = .none
        filterIcon.image = type.iconImage
        filterLabel.text = type.title
        contentsCountLabel.text = "\(count)"
    }
}

extension FilterTableViewCell {
    private func setUpConstraints() {
        addSubview(filterIcon)
        addSubview(filterLabel)
        addSubview(contentsCountLabel)
        
        NSLayoutConstraint.activate([
            filterIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            filterIcon.widthAnchor.constraint(equalToConstant: 24),
            filterIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            filterLabel.leadingAnchor.constraint(equalTo: filterIcon.trailingAnchor, constant: 24),
            filterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            contentsCountLabel.leadingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            contentsCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
