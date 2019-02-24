//
//  JournalChangeViewController.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 19..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit

class JournalChangeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var tableView: UITableView!
    
    private let cellHeight: CGFloat = 40
    private var numberOfJournal: Int!
    private var heightConstant: CGFloat = 40
    
    private var journals: [Journal] = []
    
    var alertController: UIAlertController!
    weak var journalChangeDelegate: JournalChangeDelegate?

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadJournals()
        setUpTableView()
    }
    
    private func loadJournals() {
        journals = CoreDataManager.shared.journalsWithoutDefault
        numberOfJournal = journals.count
        if numberOfJournal == 1 {
            heightConstant = 44
        } else {
            heightConstant = min(CGFloat(numberOfJournal) * cellHeight, 200)
        }
        
    }
    
    private func setUpTableView() {
        tableView = UITableView()
        tableView.backgroundColor = UIColor.doBlue
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "journalChangeTableViewCell"
        )
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension JournalChangeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfJournal
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "journalChangeTableViewCell")
    
        cell.backgroundColor = journals[indexPath.row].color
        cell.textLabel?.text = journals[indexPath.row].title
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
            self.alertController.view.center = CGPoint(
                x: self.alertController.view.center.x,
                y: self.alertController.view.center.y + 500
            )
        }, completion: { _ in
            self.dismiss(animated: true) {
                self.journalChangeDelegate?.changeJournal(to: self.journals[indexPath.row])
            }
        })
    }
}
