//
//  CollectedEntriesHeaderMapView.swift
//  OneDay
//
//  Created by 정화 on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import MapKit

class MapPinLocation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
  
class CollectedEntriesHeaderMapView: MKMapView, MKMapViewDelegate {

    private var coordinates: [MapPinLocation] = []
    
    private var initialLocation = CLLocation(latitude: 0, longitude: 0)
    private var regionRadius: CLLocationDistance = 0
    
    func bind(coordinates: [MapPinLocation], initialLocation: CLLocation, regionRadius: CLLocationDistance) {
        self.coordinates = coordinates
        self.initialLocation = initialLocation
        self.regionRadius = regionRadius
        setCenterOfMap(on: initialLocation)
        addAnotationOnMap(coordinates)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(
            annotation: annotation,
            reuseIdentifier: "collectedEntriesMapId")
        if regionRadius < 5000000 {
            return setupAnnotationView(annotationView, size: 20)
        } else {
            return setupAnnotationView(annotationView, size: 10)
        }
    }
    
    fileprivate func setCenterOfMap(on location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: false)
    }
    
    fileprivate func setupAnnotationView(
        _ annotationView: MKAnnotationView,
        size: CGFloat
        ) -> MKAnnotationView {
        annotationView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        annotationView.backgroundColor = .gray
        annotationView.alpha = 0.5
        annotationView.layer.cornerRadius = size/2
        return annotationView
    }
    
    fileprivate func addAnotationOnMap(_ coordinates: [MapPinLocation]) {
        for index in 0..<coordinates.count {
            addAnnotation(coordinates[index])
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        delegate = self
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
