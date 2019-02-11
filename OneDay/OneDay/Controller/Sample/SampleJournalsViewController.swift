//
//  SampleJournalsViewController.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class SampleJournalsViewController: UIViewController {
        
    @IBOutlet weak var journalTable: UITableView!
    var coreDataStack: CoreDataStack!
    var journalsCount = 0
    private let cellIdentifier = "journal_cell"
    
    lazy var fetchedResultsController: NSFetchedResultsController<Journal> = {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "Journal")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataStack = CoreDataStack(modelName: "OneDay")
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is UITableViewCell {
            if let cell = sender as? UITableViewCell, let indexPath = journalTable.indexPath(for: cell) {
                guard let destination = segue.destination as? TimeLineViewController else {
                    return
                }
                let journal = fetchedResultsController.object(at: indexPath)
                destination.journal = journal
                destination.coreDataStack = coreDataStack
            }
        }
    }
    
    @IBAction func alertAddJournal(_ sender: Any) {
        let alert = UIAlertController(title: "New Jornal", message: "Write the title", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .emailAddress
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            if let textField = alert.textFields?.first {
                self.journal(title: textField.text)
            }
        })
        
        present(alert, animated: true)
    }
    
    func journal(title: String?) {
        print("create new journal")
        let journal = Journal(context: coreDataStack.managedContext)
        let index = journalsCount + 1
        journal.title = title ?? "New Journal"
        journal.index = index as NSNumber
        journal.journalId = UUID.init()
        self.coreDataStack.saveContext()
    }
}

extension SampleJournalsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        journalsCount = sectionInfo.numberOfObjects
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let journal = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withCampSite: journal)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, withCampSite journal: Journal?) {
        guard let data = journal, let title = data.title else { return }
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "엔트리 \(data.entries?.count ?? 0)개"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case(.delete) = editingStyle else { return }
        
        coreDataStack.managedContext.delete(fetchedResultsController.object(at: indexPath))
        coreDataStack.saveContext()
    }
}

extension SampleJournalsViewController: NSFetchedResultsControllerDelegate {

    //
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        journalTable.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            journalTable.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            journalTable.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            journalTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            journalTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(journalTable.cellForRow(at: indexPath!)!, withCampSite: anObject as? Journal)
        case .move:
            journalTable.deleteRows(at: [indexPath!], with: .fade)
            journalTable.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        journalTable.endUpdates()
    }
}
