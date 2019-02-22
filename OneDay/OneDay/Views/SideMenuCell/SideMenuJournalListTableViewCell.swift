//
//  SideMenuJournalListTableViewCell.swift
//  OneDayProto
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

/// 사이드 메뉴에서 저널 목록을 보여주는 셀
class SideMenuJournalListTableViewCell: UITableViewCell {
    
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
        setConstraints()
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

extension SideMenuJournalListTableViewCell {
    private func setConstraints() {
        addSubview(roundBackgroundView)
        roundBackgroundView.addSubview(titleLabel)
        roundBackgroundView.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            roundBackgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            roundBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            roundBackgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            roundBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            titleLabel.leftAnchor.constraint(equalTo: roundBackgroundView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: roundBackgroundView.rightAnchor, constant: -40),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            countLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countLabel.widthAnchor.constraint(equalToConstant: 32)
            ])
    }
}
