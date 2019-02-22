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
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    private let settingIdentifier = "settingCellIdentifier"
    /// [section][row]
    private var settingTableData: [[EntrySetting]] = [[],[],[]]
    
    private let regionRadius: CLLocationDegrees = 1000
    
    private  let generator = UIImpactFeedbackGenerator(
        style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    ///하단 뷰 아래로 드래그시 아래로 붙는 기준
    private var dragDownChangePoint: CGFloat = 100
    ///드래그 종료시 변경되야하는지 여부
    private var willPositionChange = false
    private var canScroll = false
    
    var entry: Entry!
    var topViewDateLabel: UILabel!
    var topViewFavoriteImage: UIImageView!
    weak var statusChangeDelegate: StateChangeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setUpSettingTableBaseSectionData()
        setUpSettingTableDaySectionData()
        setUpSettingTableEctSectionData()
        setUpDate()
        setUpLocation()
        setUpWeather()
        setUpDevice()
        setUpMap()
    }
    
    // MARK: - Set up
    
    private func setUpTable() {
        tableView.register(
            EditorSettingTableViewCell.self,
            forCellReuseIdentifier: settingIdentifier
        )
        tableView.isScrollEnabled = false
    }
    
    private func setUpSettingTableBaseSectionData() {
        let location = EntrySetting(
            title: "위치",
            detail: "",
            image: UIImage(named: "setting_location")
        )
        location.accessoryType = .disclosureIndicator
        settingTableData[0].append(location)
        
        let tag = EntrySetting(
            title: "태그",
            detail: "추가...",
            image: UIImage(named: "setting_tag")
        )
        tag.accessoryType = .disclosureIndicator
        settingTableData[0].append(tag)
        
        let journal = EntrySetting(
            title: "일기장",
            detail: "",
            image: UIImage(named: "setting_journal")
        )
        if let journalTitle = entry.journal?.title {
            journal.detail = journalTitle
        }
        journal.accessoryType = .disclosureIndicator
        settingTableData[0].append(journal)
        
        let date = EntrySetting(
            title: "날짜",
            detail: "",
            image: UIImage(named: "setting_date")
        )
        date.accessoryType = .disclosureIndicator
        settingTableData[0].append(date)
        
        if entry.favorite {
            let favorite = EntrySetting(
                title: "즐겨찾기",
                detail: "즐겨찾기 해제",
                image: UIImage(named: "setting_like")
            )
            settingTableData[0].append(favorite)
            topViewFavoriteImage.isHidden = false
        } else {
            let favorite = EntrySetting(
                title: "즐겨찾기",
                detail: "즐겨찾기 설정",
                image: UIImage(named: "setting_dislike")
            )
            settingTableData[0].append(favorite)
            topViewFavoriteImage.isHidden = true
        }
    }
    
    private func setUpSettingTableDaySectionData() {
        let thisDay = EntrySetting(
            title: "이날에:",
            detail: "",
            image: UIImage(named: "setting_thisday")
        )
        thisDay.accessoryType = .disclosureIndicator
        settingTableData[1].append(thisDay)
        let today = EntrySetting(
            title: "이 날:",
            detail: "",
            image: UIImage(named: "setting_today")
        )
        today.accessoryType = .disclosureIndicator
        settingTableData[1].append(today)
    }
    
    private func setUpSettingTableEctSectionData() {
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
    
    private func setUpDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "YYYY년 MM월 dd일, a h:mm"
        let fullDate = dateFormatter.string(from: entry.date)
        settingTableData[0][3].detail = fullDate
        
        let date = entry.date
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let entriesOnThisDay = CoreDataManager.shared.filter(
            by: [.thisDay(month: month, day: day)])
        let entriesAtDay = CoreDataManager.shared.filter(
            by:[.thisYear(year: year),
                .thisDay(month: month, day: day)])
        
        settingTableData[1][0].title = "이날에: \(month)월 \(day)일"
        settingTableData[1][0].detail = "\(entriesOnThisDay.count) Entries"
        settingTableData[1][1].title = "이 날: \(year)년 \(month)월 \(day)일"
        settingTableData[1][1].detail = "\(entriesAtDay.count) Entries"
    }
    
    private func setUpWeather() {
        if let weather = entry.weather {
            guard let type = weather.type else { return }
            if let weatherType = WeatherType(rawValue: type) {
                settingTableData[2][0].detail = "\(weather.tempature)℃ \(weatherType.summary)"
                settingTableData[2][0].image = UIImage(named: "setting-\(weatherType.rawValue)")
            } else {
                settingTableData[2][0].detail = "\(weather.tempature)℃"
            }
        } else {
            let weather = CoreDataManager.shared.insertWeather()
            entry.weather = weather
            updateWeather()
        }
    }
    
    private func setUpLocation() {
        if let location = entry.location {
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
            entry.location = location

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
                    self?.showAlert(title: "Error", message: "위치 정보를 불러올 수 없습니다.")
            })
        }
    }
    
    private func setUpDevice() {
        if let entryDevice = entry.device {
            if let entryDeviceName = entryDevice.name, let entryDeviceModel = entryDevice.model {
                settingTableData[2][1].detail = "\(entryDeviceName), \(entryDeviceModel)"
            }
        } else {
            let device = CoreDataManager.shared.insertDevice()
            entry.device = device
            device.name = UIDevice.current.name
            device.model = UIDevice.current.model
            settingTableData[2][1].detail = "\(UIDevice.current.name), \(UIDevice.current.model)"
        }
    }
    
    private func setUpMap() {
        var initialLocation = CLLocation()
        let point = CustomPointAnnotation()
        if let location = entry.location {
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
    
    private func updateWeather() {
        guard let weather = entry.weather, let location = entry.location else { return }
        WeatherService.service.weather(
            latitude: location.latitude,
            longitude: location.longitude,
            date: entry.date,
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
                self?.showAlert(title: "Error", message: "날씨 정보를 불러올 수 없습니다.")
                DispatchQueue.main.sync {
                    self?.entry.weather?.type = "unKnown"
                    self?.settingTableData[2][0].image = UIImage(named: "setting_weather")
                    self?.settingTableData[2][0].detail = ""
                    self?.tableView.reloadData()
                }
        })
    }
    
    // MARK: - MAP
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Alert
    
    private func showAlert(title: String = "", message: String = "") {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "확인",
            style: .default,
            handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extention

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
            for: indexPath ) as? EditorSettingTableViewCell else {
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
            case 2:
                changeJournal()
            case 3:
                changeDate()
            case 4:
                toggleFavorite()
                tableView.reloadData()
            default:
                return
            }
        case .day:
            switch indexPath.row {
            case 0:
                presentThisDayEntries()
            case 1:
                presentAtDayEntries()
            default:
                return
            }
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

// MARK: Cell select actions

extension EntryInformationViewController {
    
    private func changeJournal() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let journalChangeViewController = JournalChangeViewController()
        journalChangeViewController.alertController = alert
        journalChangeViewController.journalChangeDelegate = self
        alert.setValue(journalChangeViewController, forKey: "contentViewController")
        self.present(alert, animated: false) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    private func changeDate() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let datePickerViewController = DatePickerViewController()
        datePickerViewController.date = self.entry.date
        let okAction = UIAlertAction(title: "확인", style: .cancel) { [weak self]_ in
            let date = datePickerViewController.datePicker.date
            self?.entry.date = datePickerViewController.datePicker.date
            self?.entry.updateDate(date: date)
            let dateSet: DateStringSet = DateStringSet(date: self?.entry.date)
            self?.topViewDateLabel.text = dateSet.full
            self?.setUpDate()
            self?.updateWeather()
            self?.tableView.reloadData()
        }
        alert.addAction(okAction)
        alert.setValue(datePickerViewController, forKey: "contentViewController")
        self.present(alert, animated: false) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    private func toggleFavorite() {
        entry.favorite.toggle()
        if entry.favorite {
            settingTableData[0][4].detail = "즐겨찾기 해제"
            settingTableData[0][4].image = UIImage(named: "setting_like")
            topViewFavoriteImage.isHidden = false
        } else {
            settingTableData[0][4].detail = "즐겨찾기 설정"
            settingTableData[0][4].image = UIImage(named: "setting_dislike")
            topViewFavoriteImage.isHidden = true
        }
    }
    
    private func presentThisDayEntries() {
        let date = entry.date
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let entriesOnThisDay = CoreDataManager.shared.filter(
            by: [.thisDay(month: month, day: day)])
        
        let collectedEntriesViewController = CollectedEntriesViewController()
        collectedEntriesViewController.dateLabel.text = "\(month)월 \(day)일"
        collectedEntriesViewController.entriesData = entriesOnThisDay
        self.present(collectedEntriesViewController, animated: true, completion: nil)
    }
    
    private func presentAtDayEntries() {
        let date = entry.date
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let entriesAtDay = CoreDataManager.shared.filter(
            by:[.thisYear(year: year),
                .thisDay(month: month, day: day)])
        
        let collectedEntriesViewController = CollectedEntriesViewController()
        collectedEntriesViewController.dateLabel.text = "\(month)월 \(day)일"
        collectedEntriesViewController.entriesData = entriesAtDay
        self.present(collectedEntriesViewController, animated: true, completion: nil)
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: MapView

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

// MARK: StateChangeDelegate

extension EntryInformationViewController: StateChangeDelegate {
    func changeState() {
        tableView.isScrollEnabled = true
        canScroll = true
    }
}

// MARK: JournalChangeDelegate

extension EntryInformationViewController: JournalChangeDelegate {
    func changeJournal(to journal: Journal) {
        entry.journal = journal
        if let title = journal.title {
            settingTableData[0][2].detail = title
            tableView.reloadData()
        }
    }
}

// MARK: - enum

private enum Section: Int {
    case base
    case day
    case etc
}
