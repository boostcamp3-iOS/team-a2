//
//  CollectedEntriesMapCell.swift
//  OneDay
//
//  Created by 정화 on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import MapKit

class CustomMapPin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class CollectedEntriesMapCell: UITableViewCell, MKMapViewDelegate {
    let mapView = MKMapView()

    let artwork = [CustomMapPin(coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661)),
                   CustomMapPin(coordinate: CLLocationCoordinate2D(latitude: 21.283341, longitude: -157.831661))
    ]
    func convertCoordinatesToMeters() -> CLLocationDistance {
        // 좌표 > 미터 변환: regionRadius 값을 동적으로 변화시키기 위함.
        //
        let coordinate0 = CLLocation(latitude: 21.282778, longitude: -157.829444)
        let coordinate1 = CLLocation(latitude: 21.283341, longitude: -157.831661)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        return distanceInMeters
    }
    // 이니셜 로케이션에 엔트리 첫 위치 삽입
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "collectedEntriesMapId")
        
        if regionRadius < 10000 { // 임의의 값 10km. 테스트해가면서 바꾸기, 거리가 너무 멀면 원을 그리지 않는다.
            annotationView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            annotationView.backgroundColor = .gray
            annotationView.alpha = 0.5
            annotationView.layer.cornerRadius = 10
            return annotationView
        } else {
            return annotationView
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .purple
        isUserInteractionEnabled = false
        setupMapView()
        
        centerMapOnLocation(location: initialLocation)
        mapView.addAnnotation(artwork[0])
        mapView.addAnnotation(artwork[1])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectedEntriesMapCell {
    fileprivate func setupMapView() {
        addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
    }
}
