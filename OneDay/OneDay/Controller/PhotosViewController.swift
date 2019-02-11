//
//  PhotosViewController.swift
//  OneDay
//
//  Created by juhee on 01/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    // MARK :- FIXME
    var coreDataStack: CoreDataStack = CoreDataStack(modelName: "OneDay")
    var entries: [Entry] = []
    
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let photoPredicate = NSPredicate(format: "%K != nil", #keyPath(Entry.thumbnail))
        fetchRequest.predicate = photoPredicate
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Entry.date),
            cacheName: "photo_entries")
        
        return fetchedResultsController
    }()
    
    private let reuseIdentifier = "photo_cell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 2.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewLayout()
        do {
            try fetchedResultsController.performFetch()
            entries = fetchedResultsController.fetchedObjects ?? []
            photoCollectionView.reloadData()
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    private func setCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let itemsPerRow: CGFloat = 3
        let availableWidth = (view.frame.width - (insets.left * itemsPerRow)) / 3
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: availableWidth, height: availableWidth)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        photoCollectionView.collectionViewLayout = layout
    }

}

extension PhotosViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotosCollectionViewCell else {
            preconditionFailure("No expected cell type casting by PhotosCollectionViewCell")
        }
        cell.dayLabel.text = "12"
        return cell
    }
}
