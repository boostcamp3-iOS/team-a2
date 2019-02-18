//
//  BottomViewController.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 15..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit
import MapKit

class EntryInformationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let settingIdentifier = "settingCellIdentifier"
    var settingTableData: [[EntrySetting]] = [[],[],[]]  /// [section][row]
    
    let regionRadius: CLLocationDegrees = 1000
    
    let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    var dragDownChangePoint: CGFloat = 100  ///하단 뷰 아래로 드래그시 아래로 붙는 기준
    var willPositionChange = false          ///드래그 종료시 변경되야하는지 여부
    var canScroll = false
    
    var entryViewController: EntryViewController!
    weak var statusChangeDelegate: StateChangeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()
        setUpSettingTableBaseSectionData()
        setUpSettingTableDaySectionData()
        setUpSettingTableEctSectionData()
        setUpDate()
        setUpWeather()
        setUpLocation()
        setUpDevice()
        setUpMap()
    }
    
    // MARK: - Set up
    
    func setUpTable() {
        tableView.register(
            EditorSettingTableViewCell.self,
            forCellReuseIdentifier: settingIdentifier
        )
        tableView.isScrollEnabled = false
    }
    
    func setUpSettingTableBaseSectionData() {
        let location = EntrySetting(
            title: "위치",
            detail: "",
            image: UIImage(named: "setting_location")
        )
        location.hasDisclouserIndicator = true
        settingTableData[0].append(location)
        
        let tag = EntrySetting(
            title: "태그",
            detail: "추가...",
            image: UIImage(named: "setting_tag")
        )
        tag.hasDisclouserIndicator = true
        settingTableData[0].append(tag)
        
        let journal = EntrySetting(
            title: "일기장",
            detail: "일기장",
            image: UIImage(named: "setting_journal")
        )
        journal.hasDisclouserIndicator = true
        settingTableData[0].append(journal)
        
        let date = EntrySetting(
            title: "날짜",
            detail: "",
            image: UIImage(named: "setting_date")
        )
        date.hasDisclouserIndicator = true
        settingTableData[0].append(date)
        
        if entryViewController.entry.favorite {
            let favorite = EntrySetting(
                title: "즐겨찾기",
                detail: "즐겨찾기 해제",
                image: UIImage(named: "setting_like")
            )
            settingTableData[0].append(favorite)
            entryViewController.favoriteImage.isHidden = false
        } else {
            let favorite = EntrySetting(
                title: "즐겨찾기",
                detail: "즐겨찾기 설정",
                image: UIImage(named: "setting_dislike")
            )
            settingTableData[0].append(favorite)
            entryViewController.favoriteImage.isHidden = true
        }
    }
    
    func setUpSettingTableDaySectionData() {
        let thisDay = EntrySetting(
            title: "이 날에",
            detail: "thisday",
            image: UIImage(named: "setting_thisday")
        )
        thisDay.hasDisclouserIndicator = true
        settingTableData[1].append(thisDay)
        let today = EntrySetting(
            title: "이 날",
            detail: "today",
            image: UIImage(named: "setting_today")
        )
        today.hasDisclouserIndicator = true
        settingTableData[1].append(today)
    }
    
    func setUpSettingTableEctSectionData() {
        let weather = EntrySetting(
            title: "날씨",
            detail: "",
            image: UIImage(named: "setting_weather")
        )
        settingTableData[2].append(weather)
        let device = EntrySetting(
            title: "일기를 작성한 기기",
            detail: "",
            image: UIImage(named: "setting_device")
        )
        settingTableData[2].append(device)
    }
    
    func setUpDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "YYYY년 MM월 dd일, a h:mm"
        let fullDate = dateFormatter.string(from: entryViewController.entry.date)
        settingTableData[0][3].detail = fullDate
    }
    
    func setUpWeather() {
        if let weather = entryViewController.entry.weather {
            guard let type = weather.type else { return }
            if let weatherType = WeatherType(rawValue: type) {
                settingTableData[2][0].detail = "\(weather.tempature)℃ \(weatherType.summary)"
                settingTableData[2][0].image = UIImage(named: "setting-\(weatherType.rawValue)")
            } else {
                settingTableData[2][0].detail = "\(weather.tempature)℃"
            }
        } else {
            let weather = CoreDataManager.shared.insertWeather()
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
                        if let weatherType = WeatherType(rawValue: type) {
                            self?.settingTableData[2][0].detail =
                                "\(weather.tempature)℃ \(weatherType.summary)"
                            self?.settingTableData[2][0].image =
                                UIImage(named: "setting-\(weatherType.rawValue)")
                        } else {
                            self?.settingTableData[2][0].detail = "\(weather.tempature)℃"
                        }
                        self?.tableView.reloadData()
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
             var location: Location!
             if let findLocation: Location = CoreDataManager.shared.location(
                longitude: LocationService.service.latitude,
                latitude: LocationService.service.longitude
                ) {
                location = findLocation
             } else {
                location = CoreDataManager.shared.insertLocation()
                 location.latitude = LocationService.service.latitude
                 location.longitude = LocationService.service.longitude
             }
             entryViewController.entry.location = location

            LocationService.service.currentAddress(
                success: {[weak self] data in
                    if data.results.isEmpty {
                        location.address = "위치 정보를 불러올 수 없습니다."
                    } else {
                        location.address = data.results[0].fullAddress
                    }
                    DispatchQueue.main.sync {
                        self?.settingTableData[0][0].detail = location.address
                        self?.tableView.reloadData()
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
            let device = CoreDataManager.shared.insertDevice()
            entryViewController.entry.device = device
            device.name = UIDevice.current.name
            device.model = UIDevice.current.model
            settingTableData[2][1].detail = "\(UIDevice.current.name), \(UIDevice.current.model)"
        }
    }
    
    func setUpMap() {
        var initialLocation = CLLocation()
        let point = CustomPointAnnotation()
        if let location = entryViewController.entry.location {
            initialLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            point.coordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
        } else {
            initialLocation = CLLocation(
                latitude: LocationService.service.latitude,
                longitude: LocationService.service.longitude
            )
            point.coordinate = CLLocationCoordinate2D(
                latitude: LocationService.service.latitude,
                longitude: LocationService.service.longitude
            )
        }
        
        centerMapOnLocation(location: initialLocation)
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

extension EntryInformationViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .base:
            return 5
        case .day, .etc:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .base:
            return 0
        case .day, .etc:
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .base:
            switch indexPath.row {
            case 0:
                ()
            case 1:
                ()
            case 2:
                ()
            case 3:
                changeDate(indexPath: indexPath)
            case 4:
                toggleFavorite()
                tableView.reloadRows(at: [indexPath], with: .none)
            default:
                return
            }
        case .day:
            ()
        case .etc:
            ()
        }
        
    }
    
    // MARK: ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canScroll {
            if dragDownChangePoint * -1 > scrollView.contentOffset.y, willPositionChange == false {
                willPositionChange = true
                generator.impactOccurred()
            }
            if dragDownChangePoint * -1 <= scrollView.contentOffset.y, willPositionChange == true {
                willPositionChange = false
                generator.impactOccurred()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if willPositionChange {
            canScroll = false
            tableView.isScrollEnabled = false
            willPositionChange = false
            statusChangeDelegate?.changeState()
        }
    }
}

// MARK: - Cell select actions

extension EntryInformationViewController {
    func changeDate(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let datePickerViewController = DatePickerViewController()
        datePickerViewController.date = self.entryViewController.entry.date
        let okAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            let date = datePickerViewController.datePicker.date
            self.entryViewController.entry.date = datePickerViewController.datePicker.date
            self.entryViewController.entry.updateDate(date: date)
            self.setUpDate()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        alert.addAction(okAction)
        alert.setValue(datePickerViewController, forKey: "contentViewController")
        self.present(alert, animated: false)
    }
    
    func toggleFavorite() {
        entryViewController.entry.favorite.toggle()
        if entryViewController.entry.favorite {
            settingTableData[0][4].detail = "즐겨찾기 해제"
            settingTableData[0][4].image = UIImage(named: "setting_like")
            settingTableData[0][4].hasDisclouserIndicator = false
            entryViewController.favoriteImage.isHidden = false
        } else {
            settingTableData[0][4].detail = "즐겨찾기 설정"
            settingTableData[0][4].image = UIImage(named: "setting_dislike")
            entryViewController.favoriteImage.isHidden = true
        }
    }
}

extension EntryInformationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        guard let customPointAnnotation = annotation as? CustomPointAnnotation else {
            return annotationView
        }
        annotationView?.image = UIImage(named: customPointAnnotation.imageName)
        
        return annotationView
    }
}

extension EntryInformationViewController: StateChangeDelegate {
    func changeState() {
        tableView.isScrollEnabled = true
        canScroll = true
    }
}

// MARK: - enum

private enum Section: Int {
    case base
    case day
    case etc
}
