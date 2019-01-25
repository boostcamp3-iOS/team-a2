//
//  SideMenuViewController.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .clear
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(dismissFromSideMenu)))
        
        setupSideMenuView()
        setupSearchBar()
        setupTableView()
        
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    @objc func dismissFromSideMenu(_ sender: UISwipeGestureRecognizer) {
        print("스와이프")
        if sender.direction == .right {
            dismiss(animated: false, completion: nil)
        }
    }
    
    var sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    
    // 테이블 뷰
    let sideMenuTableView = UITableView()
    
    let sideMenuView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    // 검색 바
    let searchBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.searchBarStyle = .prominent
        bar.placeholder = " Search"
        bar.sizeToFit()
        bar.backgroundImage = UIImage()
        return bar
    }()
    
    // 테이블 섹션 헤더
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .doLight
        return view
    }()
    
    @objc func tappedSearchBarView() {
        print("goForSearching")
        self.present(FilterViewController(), animated: false, completion: nil)
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
        let journalCount = ["7", "7"]
        let menuEdit = ["Edit Journals", "설정"]
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainCellId", for: indexPath) as? SideMenuMainCell else {
                preconditionFailure("SideMenuMainCell Error")
            }
            cell.mainIcon.image = UIImage(named: mainCells[indexPath.row].icon) ?? UIImage()
            cell.mainLabel.text = mainCells[indexPath.row].name
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCellId", for: indexPath) as? SideMenuJournalListCell else {
                preconditionFailure("SideMenuJournalListCell Error")
            }
            cell.journalTitleLabel.text = journalTitle[indexPath.row]
            cell.journalCountLabel.text = journalCount[indexPath.row]
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addCellId", for: indexPath) as? SideMenuJournalAddCell else {
                preconditionFailure("SideMenuJournalAddCell Error")
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editCellId", for: indexPath) as? SideMenuEditCell else {
                preconditionFailure("SideMenuViewController cellForRowAt Error")
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
        if section == 0 {return 0} else {return 5}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.present(FilterViewController(), animated: false, completion: nil)
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
        
        let tapSearchBarView = UITapGestureRecognizer(target: self, action: #selector(tappedSearchBarView))
        searchBarView.addGestureRecognizer(tapSearchBarView)
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
        sideMenuTableView.register(SideMenuMainCell.self, forCellReuseIdentifier: "mainCellId")
        sideMenuTableView.register(SideMenuJournalListCell.self, forCellReuseIdentifier: "listCellId")
        sideMenuTableView.register(SideMenuJournalAddCell.self, forCellReuseIdentifier: "addCellId")
        sideMenuTableView.register(SideMenuEditCell.self, forCellReuseIdentifier: "editCellId")
    }
    
}

// MARK: 사이드 메뉴 뷰컨으로 이동하기, Present To SideMenuViewController
extension UIViewController {
    
    @objc func swipeToSideMenu(_ sender: UIPanGestureRecognizer) {
        let sideMenuVC = SideMenuViewController()
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        sideMenuVC.modalPresentationStyle = .overCurrentContext
        present(sideMenuVC, animated: false, completion: nil)
        
        //FIXME: 블러 해제 방법을 모르겠다 일단 보류
        //        overlayBlurredBackgroundView()
        
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        view.addSubview(blurredBackgroundView)
    }
}
