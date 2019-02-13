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
    
    private let reuseIdentifier = "photo_cell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 2.0)
    
    var entries: [Entry] = []
    private let defaultFilters : [EntryFilter] = [.currentJournal, .photo]

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewLayout()
        addConditionChangeNotificationObserver()
        addDataChangeNotificationObserver()
        requestData()
    }
    
    // CoreData에서 Filter 조건을 넘기고 데이터를 받아서 CollectionView Reload
    private func requestData() {
        entries = CoreDataManager.shared.filter(by: defaultFilters)
        photoCollectionView.reloadData()
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
    // Notification Observer를 추가
    func addDataChangeNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveDataNotification(_:)),
            name: CoreDataManager.DidChangedDataNotification,
            object: nil)
    }
    func addConditionChangeNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveConditionsNotification(_:)),
            name: CoreDataManager.DidChangedFilterNotification,
            object: nil)
    }
    
    // 두 function은 현재 동일합니다. 추후에 달라질 수 있을 것 같아서 2개로 나누었습니다.
    // Data가 변경되었다는 Notification 을 받았을 때: collectionView reload
    @objc func didReceiveDataNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.requestData()
        }
    }
    // Filter Condition이 변경되었다는 을 받았을 때: collectionView reload
    @objc func didReceiveConditionsNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.requestData()
        }
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
        let entry = entries[indexPath.row]
        if let date = entry.date {
            cell.dayLabel.text = "\(date.day)"
            cell.monthAndYearLabel.text = "\(date.monthAndYear)"
        }
        
        guard let imageURL = entry.thumbnail else { preconditionFailure("No thumbnail image") }
        
        do {
            let imageData = try Data(contentsOf: imageURL)
            cell.imageView.image = UIImage(data: imageData)
        } catch {
            preconditionFailure("invalid ImageURL")
        }
        return cell
    }
}
