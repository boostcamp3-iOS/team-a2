//
//  FilterViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    // layout component
    private let filterTableView = UITableView()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.searchBarStyle = .minimal
        bar.showsCancelButton = false
        bar.sizeToFit()
        bar.backgroundColor = .white
        bar.placeholder = "검색"
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.black
        return bar
    }()
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("취소", for: UIControl.State.normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let sectionArray: [FilterSection] = [.recent, .filter, .keywords, .entries]
    private let entries: [Entry] = CoreDataManager.shared.currentJournalEntries
    private var filteredEntries: [(type: FilterTableCellType, data: Any)] = {
        var array: [(type: FilterTableCellType, data: Any)] = []
        FilterTableCellType.allCases.forEach { cellType in
            array.append((type: cellType, data: 0))
        }
        return array
    }()
    private var recentKeywords: [(keyword: String, entries: [Entry])] {
        var array = [(String, [Entry])]()
        OneDayDefaults.currentKeywords.reversed().forEach { keyword in
            array.append((keyword, entries.filter { $0.contents?.string.contains(keyword) ?? false }))
        }
        return array
    }
    private var matchedEntries: [Entry] = []
    private var isSearching = false
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        view.backgroundColor = .white
        setupSearchBarView()
        setupFilterTableView()
        
    }
    
    func tellKeyboardShouldShow() {
        searchBar.becomeFirstResponder()
    }
    
    func loadDaata() {
//        filteredEntries[.favorite] = CoreDataManager.shared.filter(by: [.favorite])
//        filteredEntries[.tag] = CoreDataManager.shared.filter(by: [.favorite])
    }
}

// MARK: 검색, SearchBar
// searchBar에 쓰인 텍스트가 dummyData에 있는지 검사한다.
extension FilterViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text != "" {
            isSearching = true
            matchedEntries = entries.filter {$0.contents?.string.contains(text) ?? false}
        } else {
            isSearching = false
        }
        filterTableView.reloadData()
    }
}

// MARK: 테이블뷰, TableView
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = sectionArray[section]
        switch item {
        case .recent:
            return !isSearching ? min(item.numberOfRows(), recentKeywords.count) : 0
        case .entries:
            return isSearching ? matchedEntries.count : 0
        default:
            return item.numberOfRows(isSearching)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = sectionArray[section]
        switch item {
        case .recent, .filter:
            return !isSearching ? item.sectionTitle : ""
        case .keywords, .entries:
            return isSearching ? item.sectionTitle : ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterSectionItem = sectionArray[indexPath.section]
        
        switch filterSectionItem {
        case .recent:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: filterSectionItem.identifier, for: indexPath) as? SearchedKeywordCell else { preconditionFailure("Cell Error") }
            let recentKeyword = recentKeywords[indexPath.row]
            cell.bind(keyword: recentKeyword.keyword, count: recentKeyword.entries.count)
            return cell
        case .filter:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: filterSectionItem.identifier,
                                                           for: indexPath) as? FilterCell
                else { preconditionFailure("Cell Error") }
            cell.bind(filter: filteredEntries[indexPath.row].type, count: 0)
            return cell
        case .keywords:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: filterSectionItem.identifier,
                                                           for: indexPath) as? SearchedKeywordCell
                else { preconditionFailure("Cell Error") }
            cell.bind(keyword: searchBar.text, count: matchedEntries.count)
            return cell
        case .entries:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: filterSectionItem.identifier,
                                                           for: indexPath) as? MatchingEntriesCell
                else { preconditionFailure("Cell Error") }
                // 검색 키워드와 일치하는 단어 색상 변경
            guard let keyword =  searchBar.text, let matchedRow = matchedEntries[indexPath.row].contents?.string else { preconditionFailure() }
            let range = (matchedRow as NSString).range(of: keyword)
            let attributedText = NSMutableAttributedString(string: matchedRow)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.doBlue, range: range)
                
            cell.matchingTextLabel.attributedText = attributedText
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let filterSectionItem = sectionArray[indexPath.section]
        switch filterSectionItem {
        case .entries:
            return 70
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let filterSectionItem = sectionArray[indexPath.section]
        switch filterSectionItem {
        case .keywords:
            guard let keyword = searchBar.text, keyword != "" else { return }
            if isSearching, !matchedEntries.isEmpty {
                presentCollectedEntries(for: matchedEntries)
                OneDayDefaults.currentKeywords.append(keyword)
            }
        case .recent:
            let recentKeyword = recentKeywords[indexPath.row]
            if !recentKeyword.entries.isEmpty {
                presentCollectedEntries(for: recentKeyword.entries)
            }
        default:
            ()
        }
    }
    
    func presentCollectedEntries(for entries: [Entry]) {
        let collectedEntiresViewController = CollectedEntriesViewController()
        collectedEntiresViewController.entriesData = matchedEntries
        present(collectedEntiresViewController, animated: true, completion: nil)
    }
}

// MARK: 레이아웃, Layout
extension FilterViewController {
    
    func setupSearchBarView() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        view.addSubview(cancelButton)
        cancelButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 4).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        
        cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc func dismissView(_ sender: UIButton) {
        self.addFadeTransition()
        self.dismiss(animated: false, completion: nil)
    }
    
    func setupFilterTableView() {
        view.addSubview(filterTableView)
        filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        filterTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        filterTableView.translatesAutoresizingMaskIntoConstraints = false

        filterTableView.delegate = self
        filterTableView.dataSource = self
        
        filterTableView.register(SearchedKeywordCell.self, forCellReuseIdentifier: FilterSection.recent.identifier)
        filterTableView.register(SearchedKeywordCell.self,
                                 forCellReuseIdentifier: FilterSection.keywords.identifier)
        filterTableView.register(MatchingEntriesCell.self,
                                 forCellReuseIdentifier: FilterSection.entries.identifier)
        filterTableView.register(FilterCell.self,
                                 forCellReuseIdentifier: FilterSection.filter.identifier)
    }
}
