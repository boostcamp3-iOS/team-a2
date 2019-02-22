//
//  CalendarCell.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    let dayLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.layer.cornerRadius = 3
        label.textAlignment = .center
        label.backgroundColor = .doLight
        label.layer.masksToBounds = true
        label.textColor = .calendarDarkColor
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cellWithEntry: Bool = false
    
    override var isSelected: Bool {
        didSet {
            if dayLabel.backgroundColor == .doBlue {
                cellWithEntry = true
            }
            
            if isSelected {
                dayLabel.backgroundColor = .calendarDarkColor
                dayLabel.textColor = .white
            } else {
                if cellWithEntry {
                    dayLabel.backgroundColor = .doBlue
                } else {
                    dayLabel.backgroundColor = .doLight
                    dayLabel.textColor = .calendarDarkColor
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .calendarBackgroundColor
        setupCellView()
    }
    
    override func prepareForReuse() {
        dayLabel.text = ""
        dayLabel.textColor = .calendarDarkColor
        dayLabel.backgroundColor = .doLight
    }
    
    private func setupCellView() {
        addSubview(dayLabel)
        dayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        dayLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        dayLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
