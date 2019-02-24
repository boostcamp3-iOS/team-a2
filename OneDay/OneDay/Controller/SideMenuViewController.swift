//
//  SideMenuViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

// 슬라이딩 했을 때 나타나는 사이드 메뉴. 필터로 이동하거나 기본 저널을 변경하거나 새로운 저널을 추가하는 등의 기능을 담고 있다.
class SideMenuViewController: UIViewController {
    // MARK: Propertieㄴ
    override var prefersStatusBarHidden: Bool { return true }
    
    // Constants
    private let defaultInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: -4)
    
    // View Lyaout Components
    private let sideMenuTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
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
    
    // MARK: Methods
    override func viewDidLoad() {
        configSubViews()
        setConstraints()
        addCoreDataChangedNotificationObserver()
    }
    
    private func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoreDataNotification,
            object: nil)
    }
    
    @objc private func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.sideMenuTableView.reloadData()
        }
    }
}

// MARK: - Extensions
extension SideMenuViewController {
     /**
     SideMenu의 UITableView에 사용할 Section enum
     
     - filters: 셀을 누르면 필터 화면으로 이동하거나 선택된 필터조건으로 필터된 엔트리들의 모아보기 화면으로 이동한다.
     - journals: 저널 섹션.
     - addJournal: 저널 섹션. 셀을 누르면 저널을 추가할 수 있다.
     - setting: 설정 섹션.
     */
    enum Section: Int, CaseIterable {
        /** filters: 필터 섹션.
         
        셀을 누르면 필터 화면으로 이동하거나 선택된 필터조건으로 필터된 엔트리들의 모아보기 화면으로 이동한다.
         */
        case filters = 0
        /** journals: 저널 섹션.
         
         셀을 누르면 기본 저널이 바뀐다. */
        case journals = 1
        /** addJournal: 저널 섹션.
         
         셀을 누르면 저널을 추가할 수 있다. */
        case addJournal = 2
        /** setting: 설정 섹션. */
        case setting = 3
        
        var sectionNumber: Int {
            return self.rawValue
        }
        
        var identifier: String {
            switch self {
            case .filters: return "side_filter_cell"
            case .journals: return "side_journal_cell"
            case .addJournal: return "side_add_journal_cell"
            case .setting: return "side_setting_cell"
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .filters: return SideMenuFilterType.allCases.count
            case .journals: return 0
            case .addJournal: return 1
            case .setting: return 1
            }
        }
        
        var heightForCell: CGFloat {
            switch self {
            case .filters:
                return 40
            default:
                return 60
            }
        }
        
        var heightForHeaderInSection: CGFloat {
            switch self {
            case .filters, .addJournal:
                return 0
            default:
                return 2
            }
        }
        
        var viewForHeaderInSection: UIView? {
            switch self {
            case .filters, .addJournal:
                return nil
            default:
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.sideMenuWidth, height: heightForHeaderInSection))
                headerView.backgroundColor = .doLight
                return headerView
            }
        }
    }
}

// MARK: UITableView Data Source
extension SideMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menuSection = Section(rawValue: section) else { return 0 }
        return menuSection == .journals ? journals.count : menuSection.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menuSection = Section(rawValue: indexPath.section) else {
            preconditionFailure("Inavlid Section")
        }
        switch menuSection {
        case .filters:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuFilterTableViewCell,
                let cellType = SideMenuFilterType(rawValue: indexPath.row) else {
                preconditionFailure("Error")
            }
            cell.bind(type: cellType)
            return cell
        case .journals:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuJournalListTableViewCell else {
                preconditionFailure("Error")
            }
            cell.bind(journal: journals[indexPath.row])
            return cell
        case .addJournal:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuJournalAddTableViewCell else {
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

// MARK: UITableView Delegate
extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let menuSection = Section(rawValue: section) else { return nil }
        return menuSection.viewForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let menuSection = Section(rawValue: section) else { return 0 }
        return menuSection.heightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuSection = Section(rawValue: indexPath.section) else {
            preconditionFailure("Inavlid Section")
        }
        
        if menuSection != .journals {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        switch menuSection {
        case .filters:
            guard let cellType = SideMenuFilterType(rawValue: indexPath.row) else { preconditionFailure() }
            cellType.selectedHandler(self)
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
                _ = CoreDataManager.shared.insertJournal(journalTitle, index: Constants.automaticNextJournalIndex)
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

// MARK: set up view component constraints
extension SideMenuViewController {
    private func configSubViews() {
        
        searchBar.isUserInteractionEnabled = true
        searchBar.delegate = self
        
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        
        sideMenuTableView.register(SideMenuFilterTableViewCell.self, forCellReuseIdentifier: Section.filters.identifier)
        sideMenuTableView.register(SideMenuJournalListTableViewCell.self, forCellReuseIdentifier: Section.journals.identifier)
        sideMenuTableView.register(SideMenuJournalAddTableViewCell.self, forCellReuseIdentifier: Section.addJournal.identifier)
        sideMenuTableView.register(SideMenuSettingTableViewCell.self, forCellReuseIdentifier: Section.setting.identifier)
    }
    
    private func setConstraints() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(sideMenuTableView)
        
        NSLayoutConstraint.activate([
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            sideMenuTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sideMenuTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            sideMenuTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sideMenuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

// MARK: UISearchBarDelegate
extension SideMenuViewController: UISearchBarDelegate {
    // 서치바를 탭하면 SearchFilterViewController 를 뿌려주고 keyboard를 올려야 한다고 알려줍니다.
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.addFadeTransition()
        let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
        guard let searchFilterViewController = storyboard.instantiateViewController(withIdentifier: "search_filter_view") as? SearchFilterViewController
            else {
                preconditionFailure()
        }
        searchFilterViewController.tellKeyboardShouldShow()
        present(searchFilterViewController, animated: false, completion: nil)
        return false
    }
}
