//
//  CalendarHeaderView.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class CalendarHeaderView: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1, alpha: 0.8)
        setupCellView()
    }
    
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    let headerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "0000년 0월"
        label.textAlignment = .center
        label.font = label.font.withSize(12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellView() {
        addSubview(headerLabel)
        headerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
