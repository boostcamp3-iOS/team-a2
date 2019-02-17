//
//  LocationService.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 1..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import CoreLocation
import Foundation

class LocationService: NSObject {
    
    // MARK: - Properties
    
    static let service = LocationService()
    private let locationManager = CLLocationManager()
    private var _latitude: String = ""
    private var _longitude: String = ""
    private var _location: CLLocation? = nil
    
    var location: CLLocation? { return _location }
    var latitude: String { return _latitude }
    var longitude: String { return _longitude }
    
    // MARK: - Methods
    
    /// 사용자 위치정보 권한 요청
    func requestAuth() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    ///위치 변경시마다 업데이트
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location: CLLocation = manager.location else { return }
        _location = location
        let coordinate: CLLocationCoordinate2D = location.coordinate
        _latitude = "\(coordinate.latitude)"
        _longitude = "\(coordinate.longitude)"
    }
}
