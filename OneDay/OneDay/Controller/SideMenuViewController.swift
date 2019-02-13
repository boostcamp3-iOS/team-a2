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
    let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    let sectionHeaderHeight: CGFloat = 5
    
    // 테이블 섹션 헤더
    lazy var sectionHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: sideMenuWidth, height: sectionHeaderHeight))
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
    
    var journals: [Journal] = CoreDataManager.shared.journals
    var currentJournal: Journal = CoreDataManager.shared.currentJournal
    let filterCells: [(name: String, icon: String)] = [("Filter", "sideMenuFilter"), ("On this Day", "sideMenuCalendar")]
    let editCells = ["Edit Journals", "설정"]
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        view.backgroundColor = .clear
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(dismissFromVC)))
        searchBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSearchBarView)))
        setupSideMenuView()
        setupSearchBar()
        setupTableView()
        
        sideMenuTableView.selectRow(at: IndexPath(row: Int(CoreDataManager.shared.currentJournal.index), section: SideMenuSection.journals.sectionNumber), animated: false, scrollPosition: .top)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuFilterCell else {
                preconditionFailure("Error")
            }
            cell.mainIcon.image = UIImage(named: filterCells[indexPath.row].icon)
            cell.mainLabel.text = filterCells[indexPath.row].name
            return cell
        case .journals:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuJournalListCell else {
                preconditionFailure("Error")
            }
            let journal = journals[indexPath.row]
            cell.journalTitleLabel.text = journal.title
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: menuSection.identifier, for: indexPath) as? SideMenuEditCell else {
                preconditionFailure("Error")
            }
            cell.editTitleLabel.text = editCells[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let menuSection = SideMenuSection(rawValue: indexPath.section) else {
            return
        }

        if menuSection == .journals {
            guard let cell = cell as? SideMenuJournalListCell else {
                return
            }
            let journal = journals[indexPath.row]
            if CoreDataManager.shared.currentJournal.journalId == journal.journalId {
                cell.setSelected(true, animated: false)
            }
       }
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuSection = SideMenuSection(rawValue: indexPath.section) else {
            preconditionFailure("Inavlid Section")
        }
        
        switch menuSection {
        case .filters:
            // TODO :- Filter Click 했을 때 조건 넘기기
            self.present(FilterViewController(), animated: false, completion: nil)
        case .journals:
            let journal = journals[indexPath.row]
            CoreDataManager.shared.changeCurrentJournal(to: journal)
        case .addJournal:
            let alertController = UIAlertController(title: "저널 추가", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "저널 이름"
            }
            let confirmAction = UIAlertAction(title: "저널 추가", style: .default) { [weak self, weak alertController] _ in
                guard let alertController = alertController, let journalTitle = alertController.textFields?.first?.text else { return }
                let journal = CoreDataManager.shared.insert(journalTitle, index: -1)
                self?.journals.append(journal)
                self?.sideMenuTableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        case .setting:
            // TODO :- 모든 항목 처리하기
            // TODO :- 설정 화면 이동
            ()
        }
    }
}

extension SideMenuViewController {
    func setupSideMenuView() {
        view.addSubview(sideMenuView)
        sideMenuView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        sideMenuView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        sideMenuView.widthAnchor.constraint(equalToConstant: sideMenuWidth).isActive = true
        sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func setupSearchBar() {
        sideMenuView.addSubview(searchBarView)
        searchBarView.leftAnchor.constraint(equalTo: sideMenuView.leftAnchor, constant: 4).isActive = true
        searchBarView.topAnchor.constraint(equalTo: sideMenuView.topAnchor, constant: 24).isActive = true
        searchBarView.rightAnchor.constraint(equalTo: sideMenuView.rightAnchor, constant: 0).isActive = true
        searchBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        searchBarView.addSubview(searchBar)
        searchBar.leftAnchor.constraint(equalTo: searchBarView.leftAnchor, constant: 0).isActive = true
        searchBar.topAnchor.constraint(equalTo: searchBarView.topAnchor, constant: 0).isActive = true
        searchBar.rightAnchor.constraint(equalTo: searchBarView.rightAnchor, constant: 0).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 0).isActive = true
        searchBar.isUserInteractionEnabled = false
    }
    
    func setupTableView() {
        sideMenuView.addSubview(sideMenuTableView)
        sideMenuTableView.leftAnchor.constraint(equalTo: sideMenuView.leftAnchor, constant: 0).isActive = true
        sideMenuTableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 16).isActive = true
        sideMenuTableView.rightAnchor.constraint(equalTo: sideMenuView.rightAnchor, constant: 0).isActive = true
        sideMenuTableView.bottomAnchor.constraint(equalTo: sideMenuView.bottomAnchor, constant: 0).isActive = true
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

// MARK: GestureRecognizer
extension UIViewController {
    @objc func swipeToSideMenu(_ sender: UISwipeGestureRecognizer) {
        let sideMenuViewController = SideMenuViewController()
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        sideMenuViewController.modalPresentationStyle = .overCurrentContext
        present(sideMenuViewController, animated: false, completion: nil)
        
        //FIXME: 블러 해제 방법을 모르겠다 일단 보류
        //        overlayBlurredBackgroundView()
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        view.addSubview(blurredBackgroundView)
    }
    
    @objc func dismissFromVC(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func tappedSearchBarView() {
        self.present(FilterViewController(), animated: false, completion: nil)
    }
}
