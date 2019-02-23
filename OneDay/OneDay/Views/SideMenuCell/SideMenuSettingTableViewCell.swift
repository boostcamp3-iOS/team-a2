//
//  SideMenuSettingTableViewCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

/// 사이드 메뉴에서 설정 셀
class SideMenuSettingTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    // Layout Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .white
        label.textColor = .black
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
    
    func bind(title: String) {
        titleLabel.text = title
    }
}

extension SideMenuSettingTableViewCell {
    private func setUpConstraints() {
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
}
