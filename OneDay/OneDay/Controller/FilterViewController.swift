//
//  FilterViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    var dummyData: [String] = []
    
    //검색을 위한 배열 및 변수
    var matchedEntriesData = [String]()
    var isSearching = false
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()
        
        setupSearchBar()
        setupFilterTableView()
        appendDummyData()
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    let filterTableView = UITableView()
    
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.searchBarStyle = .prominent
        bar.showsCancelButton = true
        bar.sizeToFit()
        bar.backgroundImage = UIImage()
        bar.placeholder = "검색"
        return bar
    }()
    
}

// MARK: 검색, SearchBar
// searchBar에 쓰인 텍스트가 dummyData에 있는지 검사한다.
extension FilterViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            filterTableView.reloadData()
        } else {
            isSearching = true
            //FIXME: searchBar.text 강제 언래핑 없이 처리하는 법
            matchedEntriesData = dummyData.filter {$0.contains(searchBar.text!)}
            filterTableView.reloadData()
        }
    }
    
}

// MARK: 테이블뷰, TableView
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isSearching ? 1 : 0
        case 1:
            return isSearching ? matchedEntriesData.count : 0
        case 2:
            return 0
        case 3:
            return !isSearching ? 6 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchedCellId", for: indexPath) as? SearchedKeywordCell else {
                preconditionFailure("SearchedKeywordCell Error")
            }
            if let keyword = searchBar.text { cell.titleLabel.text = "\"\(keyword)\"" }
            cell.countLabel.text = "\(matchedEntriesData.count)"
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchingCellId", for: indexPath) as? MatchingEntriesCell else {
                preconditionFailure("MatchingEntriesCell Error")
            }
            
            if isSearching {
                // 서치 키워드 검색 단어 색상 변경
                let range = (matchedEntriesData[indexPath.row] as NSString).range(of: searchBar.text!)
                let attributedText = NSMutableAttributedString(string: matchedEntriesData[indexPath.row])
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.doBlue, range: range)
                
                cell.matchingTextLabel.attributedText = attributedText
                
            }
            return cell
        case 2:
            //FIXME: 수정
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellId", for: indexPath) as? FilterTableCell
            return cell!
        case 3:
            let filters: [(name: String, image: String)] = [("즐겨찾기", "filterHeart"),
                                                            ("태그", "filterTag"), ("장소", "filterPlace"), ("연도", "filterYear"), ("날씨", "filterWeather"), ("작성 디바이스", "filterDevice")]
            let contentsCountList = [0, 0, 0, 0, 0, 0]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellId", for: indexPath) as? FilterTableCell else {
                preconditionFailure("FilterTableCell Error")
            }
            cell.selectionStyle = .none
            cell.filterIcon.image = UIImage(named: filters[indexPath.row].image) ?? UIImage()
            cell.filterLabel.text = filters[indexPath.row].name
            cell.contentsCountLabel.text = String(contentsCountList[indexPath.row])
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellId", for: indexPath) as? FilterTableCell else {
                preconditionFailure("FilterViewController cellForRowAt() default case Error")
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return isSearching ? "Keywords" : ""
        case 1:
            if searchBar.text == nil || searchBar.text == "" {
                return ""
            } else if !matchedEntriesData.isEmpty {
                return "Matching Entries"
            } else { return "" }
            
        case 2:
            return !isSearching ? "Recent" : ""
        case 3:
            return !isSearching ? "Filter" : ""
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? 70 : 50
    }
    
}

// MARK: 레이아웃, Layout
extension FilterViewController {
    func setupSearchBar() {
        view.addSubview(searchBar)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.black
        
        searchBar.delegate = self
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupFilterTableView() {
        view.addSubview(filterTableView)
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        
        filterTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        filterTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        filterTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
        //        filterTableView.separatorStyle = .none
        filterTableView.delegate = self
        filterTableView.dataSource = self
        
        filterTableView.register(SearchedKeywordCell.self, forCellReuseIdentifier: "searchedCellId")
        filterTableView.register(MatchingEntriesCell.self, forCellReuseIdentifier: "matchingCellId")
        
        filterTableView.register(FilterTableCell.self, forCellReuseIdentifier: "filterCellId")
        
    }
    
}
