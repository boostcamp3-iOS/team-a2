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
    // MARK: Properties
    // IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    private let entries: [Entry] = CoreDataManager.shared.currentJournalEntries
    private var matchedEntries: [Entry] = []
    private var shouldSearchBarFocused: Bool = false
    
    // MARK: - Methods
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        setupFilterTableView()
        if shouldSearchBarFocused {
            searchBar.becomeFirstResponder()
        }
    }
    
    func tellKeyboardShouldShow() {
        shouldSearchBarFocused = true
    }
    
    private func setupFilterTableView() {
        searchTable.register(SearchedKeywordCell.self, forCellReuseIdentifier: Section.keywords.identifier)
        searchTable.register(MatchingEntriesCell.self, forCellReuseIdentifier: Section.entries.identifier)
    }
    
    private func addRecentKeyword() {
        guard let keyword = searchBar.text, keyword != "" else { return }
        OneDayDefaults.addCurrentKeywords(keyword: keyword)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_navi",
            let navigationViewController = segue.destination as? UINavigationController,
            let filterContainerViewController = navigationViewController.topViewController as? RecentAndFilterViewController
            {
            filterContainerViewController.bind(entries: entries, delegator: self)
        }
    }
    
    // MARK: IBAction
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        self.addFadeTransition()
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Extensions
// MARK: 검색, SearchBar
extension SearchFilterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, !text.isEmpty {
            matchedEntries = entries.filter {$0.contents?.string.contains(text) ?? false}
            searchTable.isHidden = false
            searchTable.reloadData()
        } else {
            searchTable.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

// MARK: 테이블뷰에 사용될 Section enum 정의
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
    }
}

// MARK: UITableViewDataSource
extension SearchFilterViewController: UITableViewDataSource {
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
            guard let keyword =  searchBar.text else { preconditionFailure() }
            cell.bind(keyword: keyword, entry: matchedEntries[indexPath.row])
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SearchFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { preconditionFailure() }
        return sectionType.sectionTitle
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

// MARK: FilterViewControllerDelegate
extension SearchFilterViewController: FilterViewControllerDelegate {
    func presentCollectedEntries(for entries: [Entry], title: String = "모아보기") {
        guard !entries.isEmpty else { return }
        let collectedEntiresViewController = CollectedEntriesViewController()
        collectedEntiresViewController.entriesData = entries
        collectedEntiresViewController.dateLabel.text = title
        present(collectedEntiresViewController, animated: true, completion: nil)
    }
}
