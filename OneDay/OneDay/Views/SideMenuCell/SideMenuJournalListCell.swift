//
//  SideMenuJournalListCell.swift
//  OneDayProto
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuJournalListCell: UITableViewCell {
    
    let cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let journalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 항목"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let journalCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    func setupCellView() {
        addSubview(cellView)
        cellView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        cellView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        cellView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        cellView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        cellView.addSubview(journalTitleLabel)
        journalTitleLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 16).isActive = true
        journalTitleLabel.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -40).isActive = true
        journalTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cellView.addSubview(journalCountLabel)
        journalCountLabel.leftAnchor.constraint(equalTo: journalTitleLabel.rightAnchor, constant: 8).isActive = true
        journalCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        journalCountLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
