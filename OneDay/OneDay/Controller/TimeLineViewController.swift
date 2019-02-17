//
//  SampleJournalViewController.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class TimeLineViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var timelineTable: UITableView!
    var journal: Journal!
    let fetchedResultsController: NSFetchedResultsController<Entry> = CoreDataManager.shared.currentJournalEntriesResultsController
    
    private let cellIdentifier = "timeline_cell"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            fetchedResultsController.delegate = self
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        setupTopView()
    }
    
    // MARK: - Setup
    
    func setupTopView() {
        //테이블뷰 상단 배경 채우기
        let backgroundView = UIView(frame: CGRect(
            x: 0,
            y: -480,
            width: UIScreen.main.bounds.size.width,
            height: 480)
        )
        backgroundView.backgroundColor = UIColor.doBlue
        timelineTable.addSubview(backgroundView)
        
        //navigationBar 경계선 제거
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is UITableViewCell {
            if let cell = sender as? UITableViewCell, let indexPath = timelineTable.indexPath(for: cell) {
                guard let destination = segue.destination as? EntryViewController else {
                    return
                }
                let entry = fetchedResultsController.object(at: indexPath)
                destination.entry = entry
            }
        } else if let destination = segue.destination as? EntryViewController {
            destination.entry = CoreDataManager.shared.insert()
        }
    }
    
    @IBAction func insertEntry() {
        _ = entry()
    }
}

extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        
        guard let cell = cell as? TimeLineTableViewCell else { return }
        let entry = fetchedResultsController.object(at: indexPath)
        cell.contentLabel.text = entry.title
        
        let dateFormatter = DateFormatter.defualtInstance
        dateFormatter.dateFormat = "a HH:mm"
        cell.timeLabel.text = dateFormatter.string(from: entry.date)
        dateFormatter.dateFormat = "dd"
        cell.dayLabel.text = dateFormatter.string(from: entry.date)
        dateFormatter.dateFormat = "EEEE"
        cell.weekDayLabel.text = dateFormatter.string(from: entry.date)
        
        cell.dayLabel.isHidden = indexPath.row != 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeline_cell", for: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let entry = fetchedResultsController.sections?[section].objects?.first as? Entry else { return "섹션헤더" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "ko")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: entry.date)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case(.delete) = editingStyle else { return }
        CoreDataManager.shared.remove(entry: fetchedResultsController.object(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension TimeLineViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTable.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            timelineTable.insertSections(indexSet, with: .automatic)
        case .delete:
            timelineTable.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            timelineTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            timelineTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            guard let cell = timelineTable.cellForRow(at: indexPath!) as? TimeLineTableViewCell else { return }
            configure(cell: cell, indexPath: indexPath!)
        case .move:
            timelineTable.deleteRows(at: [indexPath!], with: .fade)
            timelineTable.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTable.endUpdates()
    }
}
