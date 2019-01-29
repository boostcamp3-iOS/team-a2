//
//  SampleCoreDataViewController.swift
//  OneDay
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class SampleCoreDataViewController: UIViewController {
        
    @IBOutlet weak var temp: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    var cachedFetchedResultController: NSFetchedResultsController<Journal>?
    var journalsCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func alertAddJournal(_ sender: Any) {
        let alert = UIAlertController(title: "New Jornal", message: "Write the title", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .emailAddress
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            if let textField = alert.textFields?.first {
                self.insertJournal(title: textField.text)
            }
        })
        
        present(alert, animated: true)
    }
    
    func insertJournal(title: String?) {
        let context = fetchedResultsController.managedObjectContext
        let service = JournalService(managedObjectContext: context)
        let index = journalsCount + 1
        _ = service.journal(title ?? "New Journal", index: index)
    }
}

extension SampleCoreDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journal", for: indexPath)
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
        
        let context = fetchedResultsController.managedObjectContext
        managedObjectContext.delete(fetchedResultsController.object(at: indexPath))
        
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}

extension SampleCoreDataViewController: NSFetchedResultsControllerDelegate {
    var fetchedResultsController: NSFetchedResultsController<Journal> {
        if cachedFetchedResultController != nil {
            return cachedFetchedResultController!
        }

        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        fetchRequest.fetchBatchSize = 10

        let sortDescriptor = NSSortDescriptor(key: #keyPath(Journal.index), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: managedObjectContext!,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: "Journal")
        aFetchedResultsController.delegate = self
        cachedFetchedResultController = aFetchedResultsController
        journalsCount = cachedFetchedResultController?.fetchedObjects?.count ?? 0

        do {
            try cachedFetchedResultController!.performFetch()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }

        return cachedFetchedResultController!
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        temp.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            temp.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            temp.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            temp.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            temp.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(temp.cellForRow(at: indexPath!)!, withCampSite: anObject as? Journal)
        case .move:
            temp.deleteRows(at: [indexPath!], with: .fade)
            temp.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        temp.endUpdates()
    }
}
