//
//  PhotosViewController.swift
//  OneDay
//
//  Created by juhee on 01/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

/// 2번째 탭인 Photos. 사진이 있는 일기들만 보여준다.
class PhotosViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: IBOutlet
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    private var entries: [Entry] = []
    private let reuseIdentifier = "photo_cell"
    private let defaultFilters : [EntryFilter] = [.currentJournal, .photo]
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        addNotifications()
        loadData()
    }
    
    /// CoreData에서 Filter 조건을 넘기고 데이터를 받아서 CollectionView Reload
    private func loadData() {
        entries = CoreDataManager.shared.filter(by: defaultFilters)
        photoCollectionView.reloadData()
    }
    
    private func configureCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let availableWidth = (view.frame.width - (sectionInsets.left * itemsPerRow)) / 3
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: availableWidth, height: availableWidth)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        photoCollectionView.collectionViewLayout = layout
    }
    
    /// Notification Observer를 추가
    private func addNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoreDataNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveEntriesFilterNotification(_:)),
            name: CoreDataManager.DidChangedEntriesFilterNotification,
            object: nil)
    }
    
    /// Core Data가 변경되었다는 Notification 을 받았을 때: collectionView reload
    @objc func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    /// Filter Condition이 변경되었다는 을 받았을 때: collectionView reload
    @objc func didReceiveEntriesFilterNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController: EntryViewController = segue.destination as? EntryViewController,
            let cell: PhotosCollectionViewCell = sender as? PhotosCollectionViewCell {
            guard let indexPath: IndexPath = photoCollectionView.indexPath(for: cell) else { return }
            nextViewController.entry = entries[indexPath.item]
        }
    }
    
    // MARK: IBAction
    
    @IBAction func showCreateEntryModalViewController(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "camera":
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                selectImage(from: .photoLibrary)
                return
            }
            selectImage(from: .camera)
        default:
            selectImage(from: .photoLibrary)
        }
    }
}

// MARK: - Extension

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
        picker.dismiss(animated: true, completion: nil)
        createEntryWithImage(pickingMediaWithInfo: info)
    }
}

// MARK: UICollectionViewDataSource
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotosCollectionViewCell else {
            preconditionFailure("No expected cell type casting by PhotosCollectionViewCell")
        }
        let entry = entries[indexPath.item]
        cell.dayLabel.text = "\(entry.day)"
        cell.monthAndYearLabel.text = "\(entry.monthAndYear)"
        
        // photos에서 사용되는 entry에는 반드시 이미지가 있어야 합니다.
        guard let fileName = entry.thumbnail else { preconditionFailure("No thumbnail image") }
        guard let imageURL = fileName.urlForDataStorage else { preconditionFailure("No thumbnail image") }
        
        do {
            let imageData = try Data(contentsOf: imageURL)
            cell.imageView.image = UIImage(data: imageData)
        } catch {
            preconditionFailure("invalid ImageURL")
        }
        return cell
    }
}
