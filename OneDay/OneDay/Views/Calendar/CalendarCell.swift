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
        label.backgroundColor = .doLight
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var shouldBeDoBlue: Bool = false
    
    override var isSelected: Bool {
        didSet {
            if dayLabel.backgroundColor == .doBlue {
                shouldBeDoBlue = true
            }
            
            if isSelected {
                dayLabel.backgroundColor = .black
                dayLabel.textColor = .white
            } else {
                if shouldBeDoBlue {
                    dayLabel.backgroundColor = .doBlue
                } else {
                    dayLabel.backgroundColor = .doLight
                    dayLabel.textColor = .black
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
        dayLabel.textColor = .black
        dayLabel.backgroundColor = .doLight
    }
    
    func setupCellView() {
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
