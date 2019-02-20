//
//  SearchFilterViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class SearchFilterViewController: UIViewController {
    // layout component
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    private let entries: [Entry] = CoreDataManager.shared.currentJournalEntries
    private var matchedEntries: [Entry] = []
    private var isSearching = false
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_navi", let navigationViewController = segue.destination as? UINavigationController {
            guard let filterContainerViewController = navigationViewController.topViewController as? RecentAndFilterViewController else { return }
            filterContainerViewController.bind(entries: entries, delegator: self)
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        self.addFadeTransition()
        self.dismiss(animated: false, completion: nil)
    }
    
    func tellKeyboardShouldShow() {
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        setupFilterTableView()
    }
}

// MARK: 검색, SearchBar
// searchBar에 쓰인 텍스트가 dummyData에 있는지 검사한다.
extension SearchFilterViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text != "" {
            isSearching = true
            matchedEntries = entries.filter {$0.contents?.string.contains(text) ?? false}
            searchTable.reloadData()
        } else {
            isSearching = false
        }
        searchTable.isHidden = !isSearching
    }
    
    func addRecentKeyword() {
        guard let keyword = searchBar.text, keyword != "" else { return }
        OneDayDefaults.addCurrentKeywords(keyword: keyword)
    }
}

// MARK: 테이블뷰, TableView
extension SearchFilterViewController {
    fileprivate enum Section: Int, CaseIterable {
    
        case keywords = 0
        case entries = 1
        
        var sectionNumber: Int {
            return self.rawValue
        }
        
        var sectionTitle: String {
            switch self {
            case .keywords: return "Keywords"
            case .entries: return "Entries"
            }
        }
        
        var identifier: String {
            switch self {
            case .keywords: return "Keywords"
            case .entries: return "Entries"
            }
        }
        
        var heightForSectionHeader: CGFloat {
            switch self {
            case .entries: return 70
            default: return 50
            }
        }
        
        var heightForCell: CGFloat {
            return 50
        }
        
        func numberOfRows(_ isSearching: Bool = false) -> Int {
            switch self {
            case .entries:
                return 0
            case .keywords:
                return 1
            }
        }
    }
}

extension SearchFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { preconditionFailure() }
        switch sectionType {
        case .entries:
            return matchedEntries.count
        case .keywords:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = Section(rawValue: section) else { preconditionFailure() }
        return sectionType.heightForSectionHeader
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { preconditionFailure() }
        return sectionType.sectionTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { preconditionFailure() }
        switch sectionType {
        case .keywords:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: sectionType.identifier,
                                                           for: indexPath) as? SearchedKeywordCell
                else { preconditionFailure("Cell Error") }
            cell.bind(keyword: searchBar.text, count: matchedEntries.count)
            return cell
        case .entries:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: sectionType.identifier,
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
        guard let sectionType = Section(rawValue: indexPath.section) else { preconditionFailure() }
        return sectionType.heightForCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let sectionType = Section(rawValue: indexPath.section) else { preconditionFailure() }
        switch sectionType {
        case .keywords:
            if !matchedEntries.isEmpty, let keyword = searchBar.text {
                presentCollectedEntries(for: matchedEntries, title: keyword)
                addRecentKeyword()
            }
        case .entries:
            addRecentKeyword()
            let storyboard = UIStoryboard(name: "Coredata", bundle: nil)
            guard let entryViewController = storyboard.instantiateViewController(withIdentifier: "entry_detail") as? EntryViewController else { return }
            entryViewController.entry = matchedEntries[indexPath.row]
            self.present(entryViewController, animated: true, completion: nil)
        }
    }
}

// MARK: 레이아웃, Layout
extension SearchFilterViewController {

    func setupFilterTableView() {
        searchTable.register(SearchedKeywordCell.self, forCellReuseIdentifier: FilterSection.keywords.identifier)
        searchTable.register(MatchingEntriesCell.self, forCellReuseIdentifier: FilterSection.entries.identifier)
    }
}

extension SearchFilterViewController: FilterViewControllerDelegate {
    func presentCollectedEntries(for entries: [Entry], title: String = "모아보기") {
        guard !entries.isEmpty else { return }
        let collectedEntiresViewController = CollectedEntriesViewController()
        collectedEntiresViewController.entriesData = entries
        collectedEntiresViewController.dateLabel.text = title
        present(collectedEntiresViewController, animated: true, completion: nil)
    }
}
