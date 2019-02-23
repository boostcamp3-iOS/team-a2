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
    func bind(locations: [MapPinLocation]) {
        setCenter(of: locations)
        addAnotation(on: locations)
    }
    
// MARK: - setCenter(of: )
    
    /**
     맵뷰의 중앙 좌표와 범위를 설정합니다.
     - Parameter locations: 엔트리 정보에 포함된 지도의 좌표 배열입니다.
     - 중앙 좌표를 알기 위해서 위도와 경도의 최댓값과 최솟값을 구해 각각의 중앙 값을 구합니다.
     지도의 좌표 체계는 일반적으로 사용하는 카타시안 좌표계나, 극 좌표계와 다르기 때문에 위와 같은 방법으로 계산할 경우
     중앙 값이 올바른지 확인하는 과정이 필요합니다. validateLogitude(_:,and:,for:) 메소드를 사용하여 확인하십시오.
     */
    private func setCenter(of locations: [MapPinLocation]) {
        var maxLatitude: CLLocationDegrees = -90.0
        var minLatitude: CLLocationDegrees = 90.0
        var maxLongitude: CLLocationDegrees = -180.0
        var minLongitude: CLLocationDegrees = 180.0
        
        locations.forEach { (entry) in
            let latitude = entry.coordinate.latitude
            let longitude = entry.coordinate.longitude
            
            minLatitude = min(latitude, minLatitude)
            maxLatitude = max(latitude, maxLatitude)
            minLongitude = min(longitude, minLongitude)
            maxLongitude = max(longitude, maxLongitude)
        }
        
        let centerLatitude = (maxLatitude + minLatitude)*0.5
        var centerLongitude = (maxLongitude + minLongitude)*0.5
        validateLogitude(maxLongitude, and: minLongitude, for: &centerLongitude)
        let center = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)

        let latitudeSpan = min((maxLatitude - minLatitude)*1.5, 180)
        var longitudeSpan = min((maxLongitude - minLongitude)*1.5, 180)
        optimizeMapView(by: &longitudeSpan)
        let span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)
        
        let coordinateRegion = MKCoordinateRegion(center: center, span: span)
        setRegion(coordinateRegion, animated: false)
    }
    
    /**
     경도의 중앙값이 맞는지 확인하는 함수입니다. 본 함수는 충분히 검증되지 않았습니다. 예외 사항이 발생할 수 있음에 유의하십시오.
     */
    private func validateLogitude(
        _ maxLongitude: CLLocationDegrees,
        and minLongitude: CLLocationDegrees,
        for centerLongitude: inout Double) {
        if maxLongitude*minLongitude < 0 && abs(maxLongitude)+abs(minLongitude) > 180 {
            centerLongitude = min(centerLongitude-180, centerLongitude)
        }
    }

    /**
     longitudeSpan의 값에 따라 지도 뷰를 최적화합니다.
     - case 0:
        엔트리 목록에 좌표가 하나만 있는 경우 latitudeSpan = 0, longitudeSpan = 0.15으로 바꿉니다.
        경도 1도는 약 111km이므로 너비를 기준으로 약 1.7km에 해당하는 거리의 지도가 맵뷰에 표시됩니다.
     - case 180:
        longitudeSpan의 최댓값은 180으로 제한되어 있습니다. 이 값을 초과하는 경우 맵 뷰가 어노테이션이 있는 범위를
        모두 보여주지 못할 수 있습니다. 사용자가 어노테이션을 찾을 수 있도록 유저 인터렉션을 허용합니다.
     - parameter longitudeSpan: 지도를 보여 줄 범위에 사용하는 longitude delta 값입니다.
     */
    private func optimizeMapView(by longitudeSpan: inout Double) {
        switch longitudeSpan {
        case 0:
            longitudeSpan = 0.015
        case 180:
            isZoomEnabled = false
            isUserInteractionEnabled = true
        default:
            ()
        }
    }
    
// MARK: - addAnotation(on: )

    private func addAnotation(on locations: [MapPinLocation]) {
        for index in 0..<locations.count {
            addAnnotation(locations[index])
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(
            annotation: annotation,
            reuseIdentifier: "collectedEntriesMapId")
        configureAnnotation(at: annotationView, size: 20)
        return annotationView
    }

    private func configureAnnotation(at annotationView: MKAnnotationView, size: CGFloat) {
        annotationView.alpha = 0.5
        annotationView.backgroundColor = .gray
        annotationView.layer.cornerRadius = size/2
        annotationView.frame = CGRect(x: 0, y: 0, width: size, height: size)
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
