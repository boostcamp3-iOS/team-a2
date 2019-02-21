//
//  SideMenuJournalAddCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuJournalAddCell: UITableViewCell {
    // MARK: Properties
    // Layout Components
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.gray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addLabel: UILabel = {
        let label = UILabel()
        label.text = "Start a New Journal!"
        label.backgroundColor = .white
        label.textColor = .doBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    private func setupCellView() {
        addSubview(borderView)
        borderView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        borderView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        borderView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        addSubview(addLabel)
        addLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
