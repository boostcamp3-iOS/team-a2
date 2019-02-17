//
//  TimelineViewController.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import CoreLocation
import UIKit

class TimelineViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var timelineTableView: UITableView!

    let fetchedResultsController: NSFetchedResultsController<Entry> =
        CoreDataManager.shared.timelineResultsController

    var shouldDayLabelVisibleIndexPath = Set<IndexPath>()
    var shouldDayLabelVisibleDateComponents = Set<[Int]>()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellId()
        setupFetchedResultsController()
        setupTopView()
    }
    
    // MARK: - Setup
    
    func setupTopView() {
        //테이블뷰 상단 배경 채우기
//        let backgroundView = UIView(
//            frame: CGRect(
//            x: 0,
//            y: -600,
//            width: UIScreen.main.bounds.size.width,
//            height: 800)
//        )
//        timelineTableView.addSubview(backgroundView)
        
        //navigationBar 경계선 제거
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    fileprivate func registerCellId() {
        timelineTableView.register(
            TimelineTableViewCell.self,
            forCellReuseIdentifier: "timelineCellId")
        timelineTableView.register(
            TimelineHeaderCell.self,
            forCellReuseIdentifier: "timelineHeaderViewId")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("세구")
        if sender is UITableViewCell {
            if let cell = sender as? UITableViewCell,
                let indexPath = timelineTableView.indexPath(for: cell) {
                guard let destination = segue.destination as? EntryViewController
                else {
                    return
                }
                let entry = fetchedResultsController.object(at: indexPath)
                destination.entry = entry
            }
        } else if let destination = segue.destination as? EntryViewController {
            destination.entry = CoreDataManager.shared.insert()
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        do {
            fetchedResultsController.delegate = self
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        guard let cell = cell as? TimelineTableViewCell
        else {
            preconditionFailure("Error")
        }
        let fetchedEntryData = fetchedResultsController.object(at: indexPath)
        cell.bind(entry: fetchedEntryData, indexPath: indexPath)
        makeVisibleDayLabels(entry: fetchedEntryData, indexPath: indexPath, cell: cell)
    }
    
    func makeVisibleDayLabels(entry: Entry, indexPath: IndexPath, cell: UITableViewCell) {
        guard let cell = cell as? TimelineTableViewCell
        else {
            preconditionFailure("Error")
        }
        let components = Calendar.current.dateComponents([.month, .day, .year], from: entry.date)
        if let month = components.month, let day = components.day, let year = components.year {
            let arrCount = shouldDayLabelVisibleDateComponents.count
            shouldDayLabelVisibleDateComponents.insert([month, day, year])
            let newArrCount = shouldDayLabelVisibleDateComponents.count
            if arrCount != newArrCount {
                shouldDayLabelVisibleIndexPath.insert(indexPath)
            }
        }
        
        if shouldDayLabelVisibleIndexPath.contains(indexPath) {
            cell.dayLabel.isHidden = false
            cell.weekDayLabel.isHidden = false
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section]
        else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timelineCellId", for: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        guard case(.delete) = editingStyle else { return }
        CoreDataManager.shared.remove(entry: fetchedResultsController.object(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let fetchedEntryData = fetchedResultsController.sections?[section].objects?.first
            as? Entry
        else {
            return UIView()
        }
        guard let headerCellView = tableView.dequeueReusableCell(
            withIdentifier: "timelineHeaderViewId"
            ) as? TimelineHeaderCell
        else {
            preconditionFailure("error")
        }
        
        let formatter = DateFormatter.defualtInstance
        formatter.dateFormat = "YYYY년 MM월"
        let sectionTitleHeader = formatter.string(from: fetchedEntryData.date)
        
        headerCellView.headerLabel.text = sectionTitleHeader
        return headerCellView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
}

extension TimelineViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
        shouldDayLabelVisibleIndexPath = []
        shouldDayLabelVisibleDateComponents = []
        timelineTableView.reloadData()
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            timelineTableView.insertSections(indexSet, with: .automatic)
        case .delete:
            timelineTableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        shouldDayLabelVisibleIndexPath = []
        shouldDayLabelVisibleDateComponents = []
        timelineTableView.reloadData()

        switch type {
        case .insert:
            timelineTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            timelineTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            guard let cell = timelineTableView.cellForRow(at: indexPath!) as? TimelineTableViewCell
            else { return }
            configure(cell: cell, indexPath: indexPath!)
        case .move:
            timelineTableView.deleteRows(at: [indexPath!], with: .fade)
            timelineTableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTableView.endUpdates()
    }
}
