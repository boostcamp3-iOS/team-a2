//
//  SideMenuViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    // Constants
    let sectionHeaderHeight: CGFloat = 2
    private let defaultInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: -4)
    // 테이블 뷰
    private let sideMenuTableView = UITableView()
    // 검색 바
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = UISearchBar.Style.minimal
        bar.placeholder = " Search"
        bar.sizeToFit()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    private var journals: [Journal] {
        return CoreDataManager.shared.journals
    }
    private var currentJournal: Journal {
        return CoreDataManager.shared.currentJournal
    }
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() { 
        setupSearchBar()
        setupTableView()
        addCoreDataChangedNotificationObserver()
    }
    
    func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoredDataNotification,
            object: nil)
    }
    
    @objc func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.sideMenuTableView.reloadData()
        }
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SideMenuSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menuSection = SideMenuSection(rawValue: section) else { return 0 }
        return menuSection == .journals ? journals.count : menuSection.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menuSection = SideMenuSection(rawValue: indexPath.section) else {
            preconditionFailure("Inavlid Section")
        }
        switch menuSection {
        case .filters:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuFilterCell,
                let cellType = SideMenuFilterCellType(rawValue: indexPath.row) else {
                preconditionFailure("Error")
            }
            cell.bind(type: cellType)
            return cell
        case .journals:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuJournalListCell else {
                preconditionFailure("Error")
            }
            let journal = journals[indexPath.row]
            let isDefaultJournal = journal == currentJournal
            cell.journalTitleLabel.text = journal.title
            cell.cellView.backgroundColor = isDefaultJournal ? .doBlue : .white
            if CoreDataManager.shared.isDefaultJournal(uuid: journal.journalId) {
                cell.journalCountLabel.text = "\(CoreDataManager.shared.journals.reduce(0, {$0 + ($1.entries?.count ?? 0)}))"
            } else {
                cell.journalCountLabel.text = "\(journal.entries?.count ?? 0)"
            }
            return cell
        case .addJournal:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuJournalAddCell else {
                preconditionFailure("Error at : \(indexPath)")
            }
            return cell
        case .setting:
            let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath)
            cell.textLabel?.text = "Edit Journals"
            return cell
        }
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let menuSection = SideMenuSection(rawValue: section) else { return nil }
        return menuSection.viewForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let menuSection = SideMenuSection(rawValue: section) else { return 0 }
        return menuSection.heightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuSection = SideMenuSection(rawValue: indexPath.section) else {
            preconditionFailure("Inavlid Section")
        }
        
        if menuSection != .journals {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        switch menuSection {
        case .filters:
            self.present(FilterViewController(), animated: false, completion: nil)
        case .journals:
            let journal = journals[indexPath.row]
            CoreDataManager.shared.changeCurrentJournal(to: journal)
            tableView.reloadData()
        case .addJournal:
            let alertController = UIAlertController(title: "저널 추가", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "저널 이름"
            }
            let confirmAction = UIAlertAction(title: "저널 추가", style: .default) { [weak self, weak alertController] _ in
                guard let alertController = alertController, let journalTitle = alertController.textFields?.first?.text else { return }
                _ = CoreDataManager.shared.insertJournal(journalTitle, index: -1)
                self?.sideMenuTableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        case .setting:
            let sideStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
            guard let editJournalViewController = sideStoryboard.instantiateInitialViewController() else { return }
            self.present(editJournalViewController, animated: true)
        }
    }
}

extension SideMenuViewController {
    
    func setupSearchBar() {
        view.addSubview(searchBar)
        view.backgroundColor = .white
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBar.isUserInteractionEnabled = true
        searchBar.delegate = self
    }
    
    func setupTableView() {
        view.addSubview(sideMenuTableView)
        sideMenuTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        sideMenuTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        sideMenuTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        sideMenuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sideMenuTableView.translatesAutoresizingMaskIntoConstraints = false
        sideMenuTableView.separatorStyle = .none
        
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self

        sideMenuTableView.register(SideMenuFilterCell.self, forCellReuseIdentifier: SideMenuSection.filters.identifier)
        sideMenuTableView.register(SideMenuJournalListCell.self, forCellReuseIdentifier: SideMenuSection.journals.identifier)
        sideMenuTableView.register(SideMenuJournalAddCell.self, forCellReuseIdentifier: SideMenuSection.addJournal.identifier)
        sideMenuTableView.register(SideMenuEditCell.self, forCellReuseIdentifier: SideMenuSection.setting.identifier)
    }
}

extension SideMenuViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.present(FilterViewController(), animated: false, completion: nil)
        return false
    }
}
