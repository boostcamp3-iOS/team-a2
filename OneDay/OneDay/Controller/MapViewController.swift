//
//  MapViewController.swift
//  OneDay
//
//  Created by juhee on 01/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationItem: UIBarButtonItem!
    let regionRadius: CLLocationDistance = 1000
    var isMyLocationMarkerVisible: Bool = false
    var entries: [Entry] = []
    var locations: [[String:Any]] = [[:]]
    var defaultFilters: [EntryFilter] = [.currentJournal]
    var fetchResultController: NSFetchedResultsController<Entry>!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(EntryAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(EntryAnnotationClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        let defaultLocation = CLLocation(latitude: 37.497016, longitude: 127.028715)
        centerMapOnLocation(location: LocationService.service.location ?? defaultLocation)
        loadData()
        addCoreDataChangedNotificationObserver()
        addEntriesFiltersChangeNotificationObserver()
    }
    
    private func loadData() {
        fetchResultController = CoreDataManager.shared.locationResultController()
        do {
            try fetchResultController.performFetch()
            
            fetchResultController.fetchedObjects?.forEach({ entry in
                guard entry.location != nil else {
                    return
                }
                let annotation = EntryAnnotation(entry: entry)
                mapView.addAnnotation(annotation)
            })
        } catch {
            fatalError()
        }
    }
    
    func edgePoints() -> (northEastCoord: CLLocationCoordinate2D, southWestCoord: CLLocationCoordinate2D) {
        let northEastPoint = CGPoint(x: (mapView.bounds.origin.x + mapView.bounds.size.width), y: mapView.bounds.origin.y)
        let southWestPoint = CGPoint(x: mapView.bounds.origin.x, y: (mapView.bounds.origin.y + mapView.bounds.size.height))
        
        let northEastCoord: CLLocationCoordinate2D = mapView.convert(northEastPoint, toCoordinateFrom: mapView)
        let southWestCoord: CLLocationCoordinate2D = mapView.convert(southWestPoint, toCoordinateFrom: mapView)
        return (northEastCoord, southWestCoord)
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
    
    @objc func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
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
        let entries: [Entry] = mapView.annotations.reduce(into: [], { array, annotation in
            guard let data = annotation as? EntryAnnotation else { return }
            return array.append(data.entry)
            })
        print(entries.count)
        let nextViewController = CollectedEntriesViewController()
        nextViewController.entriesData = entries
        present(nextViewController, animated: true, completion: nil)
    }
}
