//
//  TimelineHeaderCell.swift
//  OneDay
//
//  Created by 정화 on 17/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class TimelineHeaderCell: UITableViewCell {
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "년 월"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .calendarHeaderTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(white: 0.9, alpha: 0.4)
        setupCellView()
    }
    
    func setupCellView() {
        addSubview(headerLabel)
        headerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
