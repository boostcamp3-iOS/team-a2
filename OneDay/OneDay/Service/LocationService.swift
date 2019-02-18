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
    private var _location: CLLocation? = nil
    private var _latitude: CLLocationDegrees = 21.282778
    private var _longitude: CLLocationDegrees = -157.829444
    private var baseURL = "https://maps.googleapis.com/maps/api/geocode/json"
    private var APIKey = "AIzaSyCq4lfrP7H9azFsfmPET_rdgIcMA2loHaA"
    
    var latitude: CLLocationDegrees { return _latitude }
    var longitude: CLLocationDegrees { return _longitude }
    var location: CLLocation? { return _location }
    
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

    func currentAddress(success: @escaping (APILocation) -> Void, errorHandler: @escaping () -> Void ) {
        let urlString  = "\(baseURL)?latlng=\(_latitude),\(_longitude)&key=\(APIKey)"
        guard let url: URL = URL(string: urlString) else { return }
        NetworkProvider.request(url: url, success: success, errorHandler: errorHandler)
    }
        
    func address(from location: CLLocation) -> String? {
        let geocoder = CLGeocoder()
        var address: String?
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first,
                let subThoroughfare = placemark.subThoroughfare,
                let thoroughfare = placemark.thoroughfare,
                let locality = placemark.locality,
                let administrativeArea = placemark.administrativeArea {
                address = subThoroughfare + " " + thoroughfare + ", " + locality + " " + administrativeArea
            }
        }
        return address
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
        _latitude = coordinate.latitude
        _longitude = coordinate.longitude
    }
}
