//
//  SideMenuJournalListCell.swift
//  OneDayProto
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuJournalListCell: UITableViewCell {
    // MARK: Properties
    // Layout Components
    private let roundBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 항목"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(journal: Journal) {
        titleLabel.text = journal.title
        // 현재 선택된 journal 인지 판단하여 backgroundColor 를 변경해준다.
        if journal == CoreDataManager.shared.currentJournal {
            roundBackgroundView.backgroundColor = .doBlue
        } else {
            roundBackgroundView.backgroundColor = .white
        }
        // 모든 항목 저널인지 확인하여 모든 항목일 경우 모든 entries의 count 를 계산해준다.
        if CoreDataManager.shared.isDefaultJournal(uuid: journal.journalId) {
            countLabel.text = "\(CoreDataManager.shared.numberOfEntries)"
        } else {
            countLabel.text = "\(journal.entries?.count ?? 0)"
        }
    }
}

extension SideMenuJournalListCell {
    private func setupCellView() {
        addSubview(roundBackgroundView)
        roundBackgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        roundBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        roundBackgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        roundBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        roundBackgroundView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: roundBackgroundView.leftAnchor, constant: 16).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: roundBackgroundView.rightAnchor, constant: -40).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        roundBackgroundView.addSubview(countLabel)
        countLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8).isActive = true
        countLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        countLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
}
