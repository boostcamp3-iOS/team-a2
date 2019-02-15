//
//  BottomViewController.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 15..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit
import MapKit

class BottomViewController: UIViewController {
    
    @IBOutlet weak var bottomTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let settingIdentifier = "settingCellIdentifier"
    var settingTableData: [[Setting]] = [[],[],[]]  /// [section][row]
    
    let regionRadius: CLLocationDegrees = 1000
    
    let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    var dragDownChangePoint = CGFloat(100) ///하단 뷰 아래로 드래그시 아래로 붙는 기준
    var willPositionChange = false      ///드래그 종료시 변경되야하는지 여부
    var canScroll = false
    
    var entryViewController: EntryViewController!
    var sendDelegate: SendNotificationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpTable()
        setUpSettingTableViewData()
        setUpDate()
        setUpWeather()
        setUpLocation()
        setUpDevice()
        setUpMap()
    }
    
    func setUpTable() {
        bottomTableView.delegate = self
        bottomTableView.dataSource = self
        bottomTableView.register(
            EditorSettingTableViewCell.self,
            forCellReuseIdentifier: settingIdentifier
        )
        bottomTableView.isScrollEnabled = false
    }
    
    func setUpSettingTableViewData() {
        let location = Setting("위치", "", UIImage(named: "setting_location"))
        location.hasDisclouserIndicator = true
        settingTableData[0].append(location)
        
        let tag = Setting("태그", "추가...", UIImage(named: "setting_tag"))
        tag.hasDisclouserIndicator = true
        settingTableData[0].append(tag)
        
        let journal = Setting("일기장", "일기장", UIImage(named: "setting_journal"))
        journal.hasDisclouserIndicator = true
        settingTableData[0].append(journal)
        
        let date = Setting("날짜", "", UIImage(named: "setting_date"))
        date.hasDisclouserIndicator = true
        settingTableData[0].append(date)
        
        if entryViewController.entry.favorite {
            let favorite = Setting("즐겨찾기", "즐겨찾기 해제", UIImage(named: "setting_like"))
            settingTableData[0].append(favorite)
        } else {
            let favorite = Setting("즐겨찾기", "즐겨찾기 설정", UIImage(named: "setting_dislike"))
            settingTableData[0].append(favorite)
        }
        
        let thisDay = Setting("이 날에", "thisday", UIImage(named: "setting_thisday"))
        thisDay.hasDisclouserIndicator = true
        settingTableData[1].append(thisDay)
        let today = Setting("이 날", "today", UIImage(named: "setting_today"))
        today.hasDisclouserIndicator = true
        settingTableData[1].append(today)
        
        let weather = Setting("날씨", "", UIImage(named: "setting_weather"))
        settingTableData[2].append(weather)
        let device = Setting("일기를 작성한 기기", "", UIImage(named: "setting_device"))
        settingTableData[2].append(device)
    }
    
    func setUpDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "a h:mm, YYYY년 MM월 dd일"
        if let entryDate = entryViewController.entry.date {
            let fullDate = dateFormatter.string(from: entryDate)
            settingTableData[0][3].detail = fullDate
        } else {
            entryViewController.entry.date = Date()
            if let entryDate = entryViewController.entry.date {
                let fullDate = dateFormatter.string(from: entryDate)
                settingTableData[0][3].detail = fullDate
            }
        }
    }
    
    func setUpWeather() {
        if let weather = entryViewController.entry.weather {
            guard let type = weather.type else { return }
            
            if let summary = WeatherType(rawValue: type)?.summary {
                settingTableData[2][0].detail = "\(weather.tempature)℃ \(summary)"
            } else {
                settingTableData[2][0].detail = "\(weather.tempature)℃"
            }
        } else {
            let weather = Weather(context: entryViewController.coreDataStack.managedContext)
            entryViewController.entry.weather = weather
            
            WeatherService.service.weather(
                latitude: LocationService.service.latitude,
                longitude: LocationService.service.longitude,
                success: {[weak self] data in
                    let degree: Int = Int((data.currently.temperature - 32) * (5/9)) /// ℉를 ℃로 변경
                    weather.tempature = Int16(degree)
                    weather.type = data.currently.icon
                    weather.weatherId = UUID.init()
                    DispatchQueue.main.sync {
                        guard let type = weather.type else { return }
                        if let summary = WeatherType(rawValue: type)?.summary {
                            self?.settingTableData[2][0].detail = "\(weather.tempature)℃ \(summary)"
                        } else {
                            self?.settingTableData[2][0].detail = "\(weather.tempature)℃"
                        }
                        self?.bottomTableView.reloadData()
                    }
                },
                errorHandler: { [weak self] in
                    self?.entryViewController.showAlert(title: "Error", message: "날씨 정보를 불러올 수 없습니다.")
            })
        }
    }
    
    func setUpLocation() {
        if let location = entryViewController.entry.location {
            settingTableData[0][0].detail = location.address
        } else {
            let location = Location(context: entryViewController.coreDataStack.managedContext)
            entryViewController.entry.location = location
            
            LocationService.service.currentAddress(
                success: {[weak self] data in
                    location.address = data.results[0].fullAddress
                    location.latitude = LocationService.service.latitude
                    location.longitude = LocationService.service.longitude
                    location.locId = UUID.init()
                    DispatchQueue.main.sync {
                        self?.settingTableData[0][0].detail = location.address
                        self?.bottomTableView.reloadData()
                    }
                },
                errorHandler: { [weak self] in
                    self?.entryViewController.showAlert(title: "Error", message: "위치 정보를 불러올 수 없습니다.")
            })
        }
    }
    
    func setUpDevice() {
        if let entryDevice = entryViewController.entry.device {
            if let entryDeviceName = entryDevice.name, let entryDeviceModel = entryDevice.model {
                settingTableData[2][1].detail = "\(entryDeviceName), \(entryDeviceModel)"
            }
        } else {
            let device = Device(context: entryViewController.coreDataStack.managedContext)
            entryViewController.entry.device = device
            device.deviceId = UUID.init()
            device.name = UIDevice.current.name
            device.model = UIDevice.current.model
            settingTableData[2][1].detail = "\(UIDevice.current.name), \(UIDevice.current.model)"
        }
    }
    
    func setUpMap() {
        let initialLocation = CLLocation(
            latitude: LocationService.service.latitude,
            longitude: LocationService.service.longitude
        )
        centerMapOnLocation(location: initialLocation)
        
        let point = CustomPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(
            latitude: LocationService.service.latitude,
            longitude: LocationService.service.longitude
        )
        point.imageName = "setting_location"
        mapView.addAnnotation(point)
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
    }
    
    // MARK: - MAP
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

extension BottomViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: settingIdentifier,
            for: indexPath
            ) as? EditorSettingTableViewCell else {
                preconditionFailure("EditorSettingTableViewCell reuse error!")
        }
        cell.setting = settingTableData[indexPath.section][indexPath.row]
        return cell
    }
    
    // MARK: ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canScroll {
            if dragDownChangePoint * -1 > scrollView.contentOffset.y, willPositionChange == false {
                willPositionChange = true
                generator.impactOccurred()
                print(1)
            }
            if dragDownChangePoint * -1 <= scrollView.contentOffset.y, willPositionChange == true {
                willPositionChange = false
                generator.impactOccurred()
                print(2)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if willPositionChange {
            canScroll = false
            bottomTableView.isScrollEnabled = false
            willPositionChange = false
            sendDelegate?.sendNotification()
        }
    }
}

extension BottomViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if let customPointAnnotation = annotation as? CustomPointAnnotation {
            annotationView?.image = UIImage(named: customPointAnnotation.imageName)
        } else {
            preconditionFailure("CustomPointAnnotation cast error!")
        }
        
        return annotationView
    }
}

extension BottomViewController: SendNotificationDelegate {
    func sendNotification() {
        bottomTableView.isScrollEnabled = true
        canScroll = true
    }
}
