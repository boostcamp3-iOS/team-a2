//
//  SideMenuViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    // 테이블 섹션 헤더
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .doLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let sideMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 테이블 뷰
    let sideMenuTableView = UITableView()
    
    // 검색 바
    let searchBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .prominent
        bar.placeholder = " Search"
        bar.sizeToFit()
        bar.backgroundImage = UIImage()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        view.backgroundColor = .clear
        setupSideMenuView()
        setupSearchBar()
        setupTableView()
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 3:
            return 2
        case 2:
            return 1
        default:
            return 0
        }    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mainCells: [(name: String, icon: String)] = [("Filter", "sideMenuFilter"), ("On this Day", "sideMenuCalendar")]
        let journalTitle = ["모든 항목", "일지"]
        let journalCount = ["7", "7"] // 데이터와 연결
        let menuEdit = ["Edit Journals", "설정"]
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCellId", for: indexPath) as UITableViewCell

            cell.imageView?.image = UIImage(named: mainCells[indexPath.row].icon) ?? UIImage()
            cell.textLabel?.text = mainCells[indexPath.row].name
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCellId", for: indexPath) as? SideMenuJournalListCell else {
                preconditionFailure("Error")
            }
            cell.journalTitleLabel.text = journalTitle[indexPath.row]
            cell.journalCountLabel.text = journalCount[indexPath.row]
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addCellId", for: indexPath) as? SideMenuJournalAddCell else {
                preconditionFailure("Error")
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editCellId", for: indexPath) as? SideMenuEditCell else {
                preconditionFailure("Error")
            }
            cell.editTitleLabel.text = menuEdit[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.present(FilterViewController(), animated: false, completion: nil)
    }
}

extension SideMenuViewController {
    func setupSideMenuView() {
        view.addSubview(sideMenuView)
        sideMenuView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        sideMenuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sideMenuView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupSearchBar() {
        sideMenuView.addSubview(searchBarView)
        searchBarView.leftAnchor.constraint(equalTo: sideMenuView.leftAnchor, constant: 4).isActive = true
        searchBarView.topAnchor.constraint(equalTo: sideMenuView.topAnchor, constant: 24).isActive = true
        searchBarView.rightAnchor.constraint(equalTo: sideMenuView.rightAnchor).isActive = true
        searchBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        searchBarView.addSubview(searchBar)
        searchBar.leftAnchor.constraint(equalTo: searchBarView.leftAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: searchBarView.topAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: searchBarView.rightAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: searchBarView.bottomAnchor).isActive = true
        searchBar.isUserInteractionEnabled = false
    }
    
    func setupTableView() {
        sideMenuView.addSubview(sideMenuTableView)
        sideMenuTableView.leftAnchor.constraint(equalTo: sideMenuView.leftAnchor).isActive = true
        sideMenuTableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 16).isActive = true
        sideMenuTableView.rightAnchor.constraint(equalTo: sideMenuView.rightAnchor).isActive = true
        sideMenuTableView.bottomAnchor.constraint(equalTo: sideMenuView.bottomAnchor).isActive = true
        sideMenuTableView.translatesAutoresizingMaskIntoConstraints = false
        sideMenuTableView.separatorStyle = .none
        
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        sideMenuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mainCellId")
        sideMenuTableView.register(SideMenuJournalListCell.self, forCellReuseIdentifier: "listCellId")
        sideMenuTableView.register(SideMenuJournalAddCell.self, forCellReuseIdentifier: "addCellId")
        sideMenuTableView.register(SideMenuEditCell.self, forCellReuseIdentifier: "editCellId")
    }
    
}
