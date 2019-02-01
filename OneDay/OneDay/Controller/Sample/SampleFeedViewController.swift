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

class SampleFeedViewController: UIViewController {
    
    @IBOutlet weak var feedTable: UITableView!
    var coreDataStack: CoreDataStack!
    var journal: Journal!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.date),
            cacheName: "entries")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private let cellIdentifier = "feed_cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is UITableViewCell {
            if let cell = sender as? UITableViewCell, let indexPath = feedTable.indexPath(for: cell) {
                guard let destination = segue.destination as? EntryViewController else {
                    return
                }
                let entry = fetchedResultsController.object(at: indexPath)
                destination.entry = entry
                
                let weather = Weather(context: coreDataStack.managedContext)
                weather.icon = ""
                weather.summary = ""
                weather.entry = entry
                
                entry.weather = weather
                coreDataStack.saveContext()
            }
        } else if let destination = segue.destination as? EntryViewController {
            destination.entry = entry()
        }
    }
    
    @IBAction func insertEntry() {
        _ = entry()
    }
    
    func entry() -> Entry {
        let entry = Entry(context: self.coreDataStack.managedContext)
        
        entry.title = "새로운 메세지"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let onlyDate = dateFormatter.string(from: Date())
        entry.date = dateFormatter.date(from: onlyDate)
        dateFormatter.dateFormat = "a HH:MM"
        entry.entryId = UUID.init()
        entry.journal = journal
        
        self.coreDataStack.saveContext()
        return entry
    }
}

extension SampleFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        
        guard let cell = cell as? SampleFeedTableViewCell else { return }
        let entry = fetchedResultsController.object(at: indexPath)
        cell.contentLabel.text = entry.title
        cell.timeLabel.text = "오후 3:13"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "feed_cell", for: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let entry = fetchedResultsController.sections?[section].objects?.first as? Entry else { return "섹션헤더" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "ko")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: entry.date ?? Date())
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case(.delete) = editingStyle else { return }
        
        coreDataStack.managedContext.delete(fetchedResultsController.object(at: indexPath))
        coreDataStack.saveContext()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension SampleFeedViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        feedTable.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            feedTable.insertSections(indexSet, with: .automatic)
        case .delete:
            feedTable.deleteSections(indexSet, with: .automatic)
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
            feedTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            feedTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            guard let cell = feedTable.cellForRow(at: indexPath!) as? SampleFeedTableViewCell else { return }
            configure(cell: cell, indexPath: indexPath!)
        case .move:
            feedTable.deleteRows(at: [indexPath!], with: .fade)
            feedTable.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        feedTable.endUpdates()
    }
}
