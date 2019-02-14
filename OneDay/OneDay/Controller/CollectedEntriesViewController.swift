//
//  CollectedEntriesViewController.swift
//  OneDay
//
//  Created by 정화 on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import MapKit
import UIKit

class CollectedEntriesViewController: UIViewController {
    
    let topFloatingView: UIView = {
        let view = UIView()
        view.backgroundColor = .doBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "가가가가가가가ㅏ가가"
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.backgroundColor = .white
    }
}

extension CollectedEntriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return indexPath.section == 0 ? screenHeight*0.4: 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mapCellId", for: indexPath) as? CollectedEntriesMapCell else {
                preconditionFailure("CollectedEntriesMapCell Error")
            }

            return cell
        
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCellId", for: indexPath) as? CollectedEntriesListCell else {
                preconditionFailure("CollectedEntriesListCell Error")
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
}

extension CollectedEntriesViewController {
    fileprivate func setupTableView() {
        
        view.addSubview(topFloatingView)
        topFloatingView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        topFloatingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topFloatingView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topFloatingView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        topFloatingView.addSubview(dateLabel)
        dateLabel.leftAnchor.constraint(equalTo: topFloatingView.leftAnchor, constant: 24).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: topFloatingView.centerYAnchor).isActive = true

        topFloatingView.addSubview(doneButton)
        doneButton.rightAnchor.constraint(equalTo: topFloatingView.rightAnchor, constant: -24).isActive = true
        doneButton.centerYAnchor.constraint(equalTo: topFloatingView.centerYAnchor).isActive = true
        
        view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topFloatingView.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(CollectedEntriesMapCell.self, forCellReuseIdentifier: "mapCellId")
        tableView.register(CollectedEntriesListCell.self, forCellReuseIdentifier: "listCellId")

        tableView.delegate = self
        tableView.dataSource = self
    }
}
