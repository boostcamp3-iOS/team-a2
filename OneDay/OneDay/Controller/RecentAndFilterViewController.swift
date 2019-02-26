//
//  RecentAndFilterViewController.swift
//  OneDay
//
//  Created by juhee on 20/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

///  SearchFilterViewController 에 container view 에 들어가는 view controller
class RecentAndFilterViewController: UIViewController {
    
    // MARK: Properties
    
    // IBOutlet
    @IBOutlet weak var recentFilterTable: UITableView!
    // delegate Properties
    private weak var delegate: FilterViewControllerDelegate?
    
    private var entries: [Entry]!
    private var recentKeywords: [(keyword: String, entries: [Entry])] = []
    private var filtersArray: [(type: FilterType, data: [Any])] = {
        var array: [(type: FilterType, data: [Any])] = []
        FilterType.allCases.forEach { cellType in
            array.append((type: cellType, data: cellType.data))
        }
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recentFilterTable.register(FilterTableViewCell.self, forCellReuseIdentifier: Section.filter.identifier)
        recentFilterTable.register(SearchingKeywordTableViewCell.self, forCellReuseIdentifier: Section.recent.identifier)
        addRecentKeywordsChangedNotificationObserver()
        loadRecentKeywordsData()
    }
    
    func bind(entries: [Entry], delegator: FilterViewControllerDelegate) {
        self.entries = entries
        self.delegate = delegator
    }
    
    // MARK: Notifications
    
    private func addRecentKeywordsChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveRecentKeywordsChangedNotification(_:)),
            name: OneDayDefaults.DidChangedRecentKeywordsNotification,
            object: nil)
    }
    
    @objc private func didReceiveRecentKeywordsChangedNotification(_: Notification) {
        loadRecentKeywordsData()
    }
    
    // keywordData를 보여준다.
    private func loadRecentKeywordsData() {
        var array = [(String, [Entry])]()
        let originKeywords = OneDayDefaults.currentKeywords
        let maximumCount: Int = min(Constants.minimumRecentKeywordsCount, originKeywords.count)
        var keywords = OneDayDefaults.currentKeywords.reversed()[0..<maximumCount]
        for index in 0..<maximumCount {
            let keyword = keywords[index]
            array.append((keyword, entries.filter { $0.contents?.string.contains(keyword) ?? false }))
        }
        recentKeywords = array
        recentFilterTable.reloadData()
    }
}

// MARK: - Extensions

// MARK: UITableView에서 사용할 Section enum

extension RecentAndFilterViewController {
    enum Section: Int {
        case recent = 0
        case filter = 1
        
        var sectionNumber: Int {
            return self.rawValue
        }
        
        var sectionTitle: String {
            switch self {
            case .recent: return "최근"
            case .filter: return "필터"
            }
        }
        
        var identifier: String {
            switch self {
            case .recent: return "recent_cell"
            case .filter: return "filter_cell"
            }
        }
        
        var heightForSection: CGFloat {
            return 50
        }
    }
}

// MARK: UITableView Data Source

extension RecentAndFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { preconditionFailure() }
        return sectionType.sectionTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { preconditionFailure() }
        if sectionType == .recent {
            return recentKeywords.count
        } else {
            return filtersArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { preconditionFailure() }
        switch sectionType {
        case .recent:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: sectionType.identifier, for: indexPath) as? SearchingKeywordTableViewCell else { preconditionFailure("Cell Error") }
            let recentKeyword = recentKeywords[indexPath.row]
            cell.bind(keyword: recentKeyword.keyword, count: recentKeyword.entries.count)
            return cell
        case .filter:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: sectionType.identifier,
                                                           for: indexPath) as? FilterTableViewCell
                else { preconditionFailure("Cell Error") }
            let filterData = filtersArray[indexPath.row]
            cell.bind(filter: filterData.type, count: filterData.data.count)
            return cell
        }
    }
}

// MARK: UITableView Delegate

extension RecentAndFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else { preconditionFailure() }
        switch sectionType {
        case .recent:
            let recentKeyword = recentKeywords[indexPath.row]
            if !recentKeyword.entries.isEmpty {
                delegate?.presentCollectedEntries(for: recentKeyword.entries, title: recentKeyword.keyword)
            }
        case .filter:
            let filterData = filtersArray[indexPath.row]
            if filterData.type.isOneDepth {
                guard let entries = filterData.data as? [Entry] else { preconditionFailure() }
                delegate?.presentCollectedEntries(for: entries, title: filterData.type.title)
            } else {
                guard let filterResultViewController = storyboard?.instantiateViewController(withIdentifier: "filter_result") as? FilterResultViewController else { preconditionFailure() }
                filterResultViewController.bind(type: filterData.type, data: filterData.data, delegator: delegate)
                navigationController?.pushViewController(filterResultViewController, animated: true)
            }
        }
    }
}

// MARK: - DelegateProtocol

/// SearchFilterviewController 에 container view에 포함되어 있는 RecentAndFilterviewController 와 FilterResultViewController 에서 사용하는 Delegate Protocol 입니다.
protocol FilterViewControllerDelegate: class {
    /**
     검색된 Entries data 를 가지고 CollectedEntriesViewController 를 띄워줍니다.
     
     - Parameters:
        - for: 모아보기로 보여줄 엔트리 목록
        - title: 모아보기에서 보여줄 제목
     */
    func presentCollectedEntries(for: [Entry], title: String)
}
