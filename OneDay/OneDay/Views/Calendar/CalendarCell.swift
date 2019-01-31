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
        label.backgroundColor = .white
        label.text = ""
        label.textAlignment = .center
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }
    
    override func prepareForReuse() {
        dayLabel.text = ""
        dayLabel.backgroundColor = .white
    }
    
    override var isSelected: Bool {
            didSet {
                if isSelected && dayLabel.text != "" {
                    dayLabel.backgroundColor = .gray
                    print("isSelected")
                } else {
                    dayLabel.backgroundColor = .white
                }
            }
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
