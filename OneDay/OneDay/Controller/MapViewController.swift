//
//  MapViewController.swift
//  OneDay
//
//  Created by juhee on 01/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationItem: UIBarButtonItem!
    let regionRadius: CLLocationDistance = 1000
    var isMyLocationMarkerVisible: Bool = false
    var entries: [Entry] = []
    var defaultFilters: [EntryFilter] = [.currentJournal]
    var annotations: [MKAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addCoreDataChangedNotificationObserver()
        addEntriesFiltersChangeNotificationObserver()
        let defaultLocation = CLLocation(latitude: 37.497016, longitude: 127.028715)
        centerMapOnLocation(location: LocationService.service.location ?? defaultLocation)
    }
    
    private func loadData() {
        entries = CoreDataManager.shared.filter(by: defaultFilters)
        
        mapView.removeAnnotations(annotations)
        print(entries.count)

        guard let location = LocationService.service.location else { return }
        for index in 0..<entries.count {
            let entry = entries[index]
            
            let constant = Double(index) * 0.001
            var coordinate = location.coordinate
            coordinate.latitude += constant
            print(coordinate)
            mapView.addAnnotation(MyLocationMarker(title: "여기에서 찍힌 entris",
                                                   locationName: entry.title ?? "hi",
                                                       discipline: "Sculpture",
                                                       coordinate: coordinate))
//            centerMapOnLocation(location: location)
//            center.x = x1 + ((x2 - x1) / 2);
//            center.y = y1 + ((y2 - y1) / 2);
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    // Notification Observer를 추가
    func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoredDataNotification,
            object: nil)
    }
    func addEntriesFiltersChangeNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveEntriesFilterNotification(_:)),
            name: CoreDataManager.DidChangedEntriesFilterNotification,
            object: nil)
    }
    
    // 두 function은 현재 동일합니다. 추후에 달라질 수 있을 것 같아서 2개로 나누었습니다.
    // Data가 변경되었다는 Notification 을 받았을 때: collectionView reload
    @objc func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    // Filter Condition이 변경되었다는 을 받았을 때: collectionView reload
    @objc func didReceiveEntriesFilterNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    @IBAction func didTaplocationItem(_ sender: UIBarButtonItem) {
        if isMyLocationMarkerVisible {
            // 현재 위치를 표시하고 있고, 내 위치가 맵에서 보인다면 더 이상 내 위치를 보여주지 않습니다.
            if mapView.isUserLocationVisible {
                mapView.showsUserLocation = false
                sender.image = UIImage(named: "ic_navigation")
                isMyLocationMarkerVisible.toggle()
            } else {
                // 현재 마커를 표시하고 있고, 내 위치가 보이지 않는다면 맵을 이동합니다.
                guard let location = LocationService.service.location else { return }
                centerMapOnLocation(location: location)
            }
        } else {
            // 현재 위치를 표시하고 있지 않다면 내 위치를 표시해주고 지도의 중심을 현재 위치로 옮깁니다.
            mapView.showsUserLocation = true
            sender.image = UIImage(named: "ic_navigation_active")
            guard let location = LocationService.service.location else { return }
            centerMapOnLocation(location: location)
            isMyLocationMarkerVisible.toggle()
        }
    }
    
    @IBAction func didTapInfoItem(_ sender: Any) {
        let actionSheet = UIAlertController(title: "지도 형태", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "지도", style: .default, handler: { _ in
            self.mapView.mapType = .standard
        }))
        actionSheet.addAction(UIAlertAction(title: "위성", style: .default, handler: { _ in
            self.mapView.mapType = .satellite
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didTapEntriesItem(_ sender: Any) {
    }
}
