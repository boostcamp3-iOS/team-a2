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
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var editorButton: UIButton!
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Entry> =
        CoreDataManager.shared.timelineResultsController
    
    fileprivate var shouldShowDayLabelAtIndexPath = [String:IndexPath]()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        removeNavigatinBarBorderLine()
        setupButtonsBehindArea()
        
        registerTableviewCell()
        setupFetchedResultsController()
        dayLabelVisibilityCheck()
        addCoreDataChangedNotificationObserver()
        addEntriesFilterChangedNotificationObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EntryViewController {
            destination.entry = CoreDataManager.shared.insertEntry()
        }
    }
    
    // MARK: - Setup
    fileprivate func registerTableviewCell() {
        timelineTableView.register(
            TimelineTableViewCell.self,
            forCellReuseIdentifier: "timelineCellId")
        
    }
    
    // MARK: - Notification
    private func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoreDataNotification,
            object: nil)
    }
    
    @objc private func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }
    
    private func addEntriesFilterChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEntriesFilterChangedNotification(_:)),
            name: CoreDataManager.DidChangedEntriesFilterNotification,
            object: nil)
    }
    
    @objc private func didEntriesFilterChangedNotification(_: Notification) {
        setupFetchedResultsController()
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }
    
    // MARK: Set Up CoreData Fetched Results Controller
    fileprivate func setupFetchedResultsController() {
        fetchedResultsController = CoreDataManager.shared.timelineResultsController
        do {
            fetchedResultsController.delegate = self
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    private func reloadData() {
        dayLabelVisibilityCheck()
        timelineTableView.reloadData()
    }
    
    fileprivate func dayLabelVisibilityCheck() {
        shouldShowDayLabelAtIndexPath = [:]
        fetchedResultsController.fetchedObjects?.forEach({ entry in
            let indexPath = fetchedResultsController.indexPath(forObject: entry)
            let key = convertToDayKey(from: entry.date)
            if shouldShowDayLabelAtIndexPath[key] == nil {
                shouldShowDayLabelAtIndexPath[key] = indexPath!
            }
        })
    }
    
    // MARK: - Layout
    fileprivate func removeNavigatinBarBorderLine() {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    fileprivate func setupButtonsBehindArea() {
        let blueColorViewForTableViewTopBounceArea: UIView = {
            let view = UIView()
            view.backgroundColor = .doBlue
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        buttonBackgroundView.addSubview(blueColorViewForTableViewTopBounceArea)
        blueColorViewForTableViewTopBounceArea.bottomAnchor.constraint(
            equalTo: buttonBackgroundView.topAnchor).isActive = true
        blueColorViewForTableViewTopBounceArea.rightAnchor.constraint(
            equalTo: view.rightAnchor).isActive = true
        blueColorViewForTableViewTopBounceArea.leftAnchor.constraint(
            equalTo: view.leftAnchor).isActive = true
        blueColorViewForTableViewTopBounceArea.topAnchor.constraint(
            equalTo: view.topAnchor).isActive = true
    }
    
    fileprivate func  scrollViewDidScroll(_ scrollView: UIScrollView) {
        transparentizeButtons()
    }
    
    fileprivate func transparentizeButtons() {
        let scrollingProgress = 1 - (
            timelineTableView.contentOffset.y / buttonBackgroundView.frame.size.height
        )
        cameraButton.alpha = scrollingProgress
        editorButton.alpha = scrollingProgress
    }
}

extension TimelineViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func cameraButton(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            selectImage(from: .photoLibrary)
            return
        }
        selectImage(from: .camera)
    }
    
    fileprivate func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        createEntryWithImage(pickingMediaWithInfo: info)
    }
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        guard let cell = cell as? TimelineTableViewCell
            else {
                preconditionFailure("Error")
        }
        let fetchedEntryData = fetchedResultsController.object(at: indexPath)
        let key = convertToDayKey(from: fetchedEntryData.date)
        let hideDayLabel = shouldShowDayLabelAtIndexPath[key] != indexPath
        cell.bind(entry: fetchedEntryData, indexPath: indexPath, hideDayLabel: hideDayLabel)
    }
    
    func convertToDayKey(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.month, .day, .year], from: date)
        guard let month = components.month, let day = components.day, let year = components.year
            else {
                preconditionFailure()
        }
        return "\(year) \(month) \(day)"
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
        
        guard let entryViewController = UIStoryboard(name: "Coredata", bundle: nil)
            .instantiateViewController(withIdentifier: "entry_detail")
            as? EntryViewController
            else { return }
        entryViewController.entry = fetchedResultsController.object(at: indexPath)
        self.present(entryViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let fetchedEntryData = fetchedResultsController.sections?[section].objects?.first
            as? Entry
            else {
                return UIView()
        }
        let headerCellView = TimelineSectionHeaderView()
        
        let formatter = DateFormatter.defaultInstance
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
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        dayLabelVisibilityCheck()
        switch type {
        case .insert:
            timelineTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            timelineTableView.deleteRows(at: [indexPath!], with: .left)
        case .update:
            guard let cell = timelineTableView.cellForRow(at: indexPath!)
                as? TimelineTableViewCell
                else {
                    return
            }
            configure(cell: cell, indexPath: indexPath!)
        case .move:
            timelineTableView.deleteRows(at: [indexPath!], with: .fade)
            timelineTableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
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
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTableView.reloadData()
        timelineTableView.endUpdates()
    }
}
