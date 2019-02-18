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

class TimelineViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var timelineTableView: UITableView!

    let fetchedResultsController: NSFetchedResultsController<Entry> =
        CoreDataManager.shared.timelineResultsController
    
    fileprivate var shouldShowDayLabelAtIndexPath = Set<IndexPath>()
    fileprivate var entriesDateComponentsStore = Set<[Int]>()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopView()

        registerTableviewCell()
        setupFetchedResultsController()
        addCoreDataChangedNotificationObserver()
    }

    // MARK: - Setup
    
    func setupTopView() {
        //테이블뷰 상단 배경 채우기
//        let backgroundView = UIView(
//            frame: CGRect(
//            x: 0,
//            y: -350,
//            width: UIScreen.main.bounds.size.width,
//            height: 400)
//        )
        //navigationBar 경계선 제거
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    fileprivate func registerTableviewCell() {
        timelineTableView.register(
            TimelineTableViewCell.self,
            forCellReuseIdentifier: "timelineCellId")
        timelineTableView.register(
            TimelineHeaderCell.self,
            forCellReuseIdentifier: "timelineHeaderViewId")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EntryViewController {
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
    
    fileprivate func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            return true
    }
    
    // MARK: - Notification

    func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoredDataNotification,
            object: nil)
    }
    
    @objc func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        shouldShowDayLabelAtIndexPath = []
        entriesDateComponentsStore = []
        timelineTableView.reloadData()
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
            let arrCount = entriesDateComponentsStore.count
            entriesDateComponentsStore.insert([month, day, year])
            let newArrCount = entriesDateComponentsStore.count
            if arrCount != newArrCount {
                shouldShowDayLabelAtIndexPath.insert(indexPath)
            }
        }
        
        if shouldShowDayLabelAtIndexPath.contains(indexPath) {
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
        
        guard let nextVC = UIStoryboard(name: "Coredata", bundle: nil)
            .instantiateViewController(withIdentifier: "entry_detail")
            as? EntryViewController
            else { return }
        nextVC.entry = fetchedResultsController.object(at: indexPath)
        self.present(nextVC, animated: true)
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
