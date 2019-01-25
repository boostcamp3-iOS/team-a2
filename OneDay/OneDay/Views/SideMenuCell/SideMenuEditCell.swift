//
//  SideMenuEditCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuEditCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    let editTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .white
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SideMenuEditCell {
    func setupCellView() {
        addSubview(editTitleLabel)
        editTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        editTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
}
