//
//  FeedViewController.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTable: UITableView!
    var tempEntries: [Entry] = []
    var entries: [NSManagedObject] = []

    private let cellIdentifier = "feed_cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }

    func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entry")

        //3
        do {
            entries = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        feedTable.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let entryVC = segue.destination as? EntryViewController {
            entryVC.delegate = self
        }
    }
}

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("entries.count \(entries.count)")
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewCell else { return UITableViewCell() }

//        cell.bind(entry: tempEntries[indexPath.row])
        cell.contentLabel.text = entries[indexPath.row].value(forKey: "title") as? String
        cell.timeLabel.text = entries[indexPath.row].value(forKey: "id") as? String
        return cell
    }
}

extension FeedViewController: EntryDelegate {
    func register(new data: EntryVO) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in: managedContext)!
        let entry = NSManagedObject(entity: entity, insertInto: managedContext)

        entry.setValue(1, forKey: "id")
        entry.setValue(data.title, forKey: "title")
        do {
            try managedContext.save()
            entries.append(entry)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        feedTable.reloadData()
    }

    func update(entry: EntryVO) {

    }

}
