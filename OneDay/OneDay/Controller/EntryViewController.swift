//
//  EntryViewController.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import MobileCoreServices
import UIKit
import MapKit

class EntryViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var bottomTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var coreDataStack: CoreDataStack!
    var entry: Entry!
    
    ///드레그시 사용되는 미리보기 뷰
    let imagePreview = UIImageView()
    let textPreview = UIView()
    let previewLabel = UILabel()
    
    lazy var isImageSelected = false
    
    ///하단 뷰 드래그시 사용되는 프로퍼티
    var topConstant = CGFloat()         /// 하단 뷰 최상단
    var bottomConstant = CGFloat()      /// 하단 뷰 최하단
    var dragUpChangePoint = CGFloat()   ///하단 뷰 위로 드래그시 위로 붙는 기준
    var dragDownChangePoint = CGFloat() ///하단 뷰 아래로 드래그시 아래로 붙는 기준
    var isBottom = true                 ///하단 뷰가 아래에 있는지 여부
    var willPositionChange = false      ///드래그 종료시 변경되야하는지 여부
    
    let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    let settingIdentifier = "settingCellIdentifier"
    var settingTableData: [[Setting]] = [[],[],[]]  /// [section][row]
    
    let regionRadius: CLLocationDegrees = 1000
    
    fileprivate var bottomViewTopConstraint: NSLayoutConstraint!
    fileprivate var bottomViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textDragDelegate = self
        
        setUpSettingTableViewData()
        setUpDate()
        setUpWeather()
        setUpLocation()
        setUpDevice()
        setUpPreview()
        setUpBottomView()
        setUpMap()
        
    }
    
    // MARK: - Setup
    
    func setUpDate() {
        var dateSet: DateStringSet = DateStringSet(date: Date())
        if let entry = entry {
            dateSet = DateStringSet(date: entry.date)
            textView.attributedText = entry.contents
        }
        dateLabel.text = dateSet.full
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "a h:mm, YYYY년 MM월 dd일"
        if let entryDate = entry.date {
            let fullDate = dateFormatter.string(from: entryDate)
            settingTableData[0][3].detail = fullDate
        } else {
            entry.date = Date()
            if let entryDate = entry.date {
                let fullDate = dateFormatter.string(from: entryDate)
                settingTableData[0][3].detail = fullDate
            }
        }
    }
    
    func setUpPreview() {
        imagePreview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        textPreview.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textPreview.layer.cornerRadius = 20
        textPreview.translatesAutoresizingMaskIntoConstraints = false
        textPreview.widthAnchor.constraint(
            lessThanOrEqualToConstant: UIScreen.main.bounds.width/2
        ).isActive = true
        textPreview.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        textPreview.addSubview(previewLabel)
        
        previewLabel.textAlignment = .left
        previewLabel.numberOfLines = 0
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.topAnchor.constraint(
            equalTo: textPreview.topAnchor,
            constant: 8
        ).isActive = true
        previewLabel.bottomAnchor.constraint(
            equalTo: textPreview.bottomAnchor,
            constant: -8
        ).isActive = true
        previewLabel.leftAnchor.constraint(
            equalTo: textPreview.leftAnchor,
            constant: 8
        ).isActive = true
        previewLabel.rightAnchor.constraint(
            equalTo: textPreview.rightAnchor,
            constant: -8
        ).isActive = true
    }
    
    func setUpWeather() {
        if let weather = entry.weather {
            guard let type = weather.type else { return }
            
            if let summary = WeatherType(rawValue: type)?.summary {
                settingTableData[2][0].detail = "\(weather.tempature)℃ \(summary)"
            } else {
                settingTableData[2][0].detail = "\(weather.tempature)℃"
            }
        } else {
            let weather = Weather(context: coreDataStack.managedContext)
            entry.weather = weather
            
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
                        let cell = self?.bottomTableView.cellForRow(at: IndexPath(row: 0, section: 2))
                        if let summary = WeatherType(rawValue: type)?.summary {
                            cell?.detailTextLabel?.text = "\(weather.tempature)℃ \(summary)"
                            self?.settingTableData[2][0].detail = "\(weather.tempature)℃ \(summary)"
                        } else {
                            cell?.detailTextLabel?.text = "\(weather.tempature)℃"
                            self?.settingTableData[2][0].detail = "\(weather.tempature)℃"
                        }
                    }
                },
                errorHandler: { [weak self] in
                    self?.showAlert(title: "Error", message: "날씨 정보를 불러올 수 없습니다.")
            })
        }
    }
    
    func setUpLocation() {
        if let location = entry.location {
            settingTableData[0][0].detail = location.address
        } else {
            let location = Location(context: coreDataStack.managedContext)
            entry.location = location
            
            LocationService.service.currentAddress(
                success: {[weak self] data in
                    location.address = data.results[0].fullAddress
                    location.latitude = LocationService.service.latitude
                    location.longitude = LocationService.service.longitude
                    location.locId = UUID.init()
                    DispatchQueue.main.sync {
                        let cell = self?.bottomTableView.cellForRow(at: IndexPath(row: 0, section: 0))
                        cell?.detailTextLabel?.text = location.address
                        self?.settingTableData[0][0].detail = location.address
                    }
                },
                errorHandler: { [weak self] in
                    self?.showAlert(title: "Error", message: "위치 정보를 불러올 수 없습니다.")
            })
        }
    }
    
    func setUpDevice() {
        if let entryDevice = entry.device {
            if let entryDeviceName = entryDevice.name, let entryDeviceModel = entryDevice.model {
                settingTableData[2][1].detail = "\(entryDeviceName), \(entryDeviceModel)"
            }
        } else {
            let device = Device(context: coreDataStack.managedContext)
            entry.device = device
            device.deviceId = UUID.init()
            device.name = UIDevice.current.name
            device.model = UIDevice.current.model
            settingTableData[2][1].detail = "\(UIDevice.current.name), \(UIDevice.current.model)"
        }
    }
    
    func setUpBottomView() {
        bottomTableView.dataSource = self
        bottomTableView.delegate = self
        bottomTableView.register(
            EditorSettingTableViewCell.self,
            forCellReuseIdentifier: settingIdentifier
        )
        
        topConstant = 0
        bottomConstant = 520
        bottomTableView.translatesAutoresizingMaskIntoConstraints = false
        bottomTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomViewTopConstraint = bottomTableView.topAnchor.constraint(
            equalTo: topView.bottomAnchor,
            constant: bottomConstant
        )
        bottomViewTopConstraint.isActive = true
        bottomViewBottomConstraint = bottomTableView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: bottomConstant
        )
        bottomViewBottomConstraint.isActive = true
        
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didDrag(gestureRecognizer:))
        )
        bottomTableView.addGestureRecognizer(gesture)
        bottomTableView.isUserInteractionEnabled = true
        
        dragUpChangePoint = 400
        dragDownChangePoint = 100
        
        isBottom = true
        willPositionChange = false
    }
    
    func setUpMap() {
        let initialLocation = CLLocation(
            latitude: LocationService.service.latitude,
            longitude: LocationService.service.longitude
        )
        centerMapOnLocation(location: initialLocation)
        
        let point = CustomPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: LocationService.service.latitude, longitude: LocationService.service.longitude)
        point.imageName = "setting_location"
        mapView.addAnnotation(point)
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
    }
    
    func setUpSettingTableViewData() {
        let location = Setting("위치", "location_detail", UIImage(named: "setting_location"))
        location.hasDisclouserIndicator = true
        settingTableData[0].append(location)
        
        let tag = Setting("태그", "추가...", UIImage(named: "setting_tag"))
        tag.hasDisclouserIndicator = true
        settingTableData[0].append(tag)
        
        let journal = Setting("일기장", "일기장", UIImage(named: "setting_journal"))
        journal.hasDisclouserIndicator = true
        settingTableData[0].append(journal)
        
        let date = Setting("날짜", "date_detail", UIImage(named: "setting_date"))
        date.hasDisclouserIndicator = true
        settingTableData[0].append(date)
        
        if entry.favorite {
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

        let weather = Setting("날씨", "weather_detail", UIImage(named: "setting_weather"))
        settingTableData[2].append(weather)
        let device = Setting("일기를 작성한 기기", "device_detail", UIImage(named: "setting_device"))
        settingTableData[2].append(device)
    }
    
    // MARK: - Actions
    
    @IBAction func showPhoto(_ sender: UIButton) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.allowsEditing = true
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveAndDismiss(_ sender: UIButton) {
        guard let content = textView.attributedText else {
            return
        }
        entry.contents = content
        
        let title: String
        let stringContent = content.string
        if stringContent.count > 1 {
            let start = stringContent.startIndex
            let end = stringContent.index(start, offsetBy: min(stringContent.count - 1, 40))
            title = String(stringContent[start...end])
        } else {
            title = "새로운 엔트리"
        }
        
        entry.title = title
        entry.favorite = false
        coreDataStack.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String = "", message: String = "") {
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
    
    // MARK: - Gesture
    
    @objc func didDrag(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: view)
            var distance = translation.y
            distance += isBottom ? bottomConstant : topConstant
            distance = min(bottomConstant, distance)
            distance = max(topConstant, distance)
        
            bottomViewTopConstraint.constant = distance
            bottomViewBottomConstraint.constant = distance
            
            if isBottom {
                if !willPositionChange && distance <= dragUpChangePoint {
                    willPositionChange = true
                    generator.impactOccurred()
                } else if willPositionChange && distance > dragUpChangePoint {
                    willPositionChange = false
                    generator.impactOccurred()
                }
            }
        } else if gestureRecognizer.state == .ended {
            changeBottomTableViewConstraints()
        }
    }
    
    func changeBottomTableViewConstraints() {
        if isBottom, willPositionChange {
            isBottom = false
            bottomTableView.isScrollEnabled = true
            bottomTableView.gestureRecognizers?.removeLast()
            self.bottomViewTopConstraint.constant = self.topConstant
            self.bottomViewBottomConstraint.constant = self.topConstant
        } else {
            isBottom = true
            self.bottomViewTopConstraint.constant = self.bottomConstant
            self.bottomViewBottomConstraint.constant = self.bottomConstant
        }
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
        willPositionChange = false
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

// MARK: - Extention

extension EntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        insertAtTextViewCursor(attributedString: createAttributedString(with: image))
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapAndHideKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func createAttributedString(with image: UIImage) -> NSAttributedString {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width
        let scaleFactor = oldWidth / (textView.frame.size.width - 10)
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        return attrStringWithImage
    }
    
    fileprivate func insertAtTextViewCursor(attributedString: NSAttributedString) {
        guard let selectedRange = textView.selectedTextRange else {
            return
        }
        
        /// attributedString을 cursor위치에 넣는다.
        let cursorIndex = textView.offset(
            from: textView.beginningOfDocument,
            to: selectedRange.start
        )
        let mutableAttributedText = NSMutableAttributedString(
            attributedString: textView.attributedText
        )
        mutableAttributedText.insert(attributedString, at: cursorIndex)
        textView.attributedText = mutableAttributedText
    }
}

extension EntryViewController: UITextDragDelegate {
    
    func textDraggableView(
        _ textDraggableView: UIView & UITextDraggable,
        dragPreviewForLiftingItem item: UIDragItem,
        session: UIDragSession
    ) -> UITargetedDragPreview? {
        
        /// 드래그 프리뷰가 시작될 위치
        let target = UIDragPreviewTarget(
            container: textView,
            center: session.location(in: textDraggableView)
        )
        
        if isImageSelected {
            isImageSelected = false
            return UITargetedDragPreview(
                view: imagePreview,
                parameters: UIDragPreviewParameters(),
                target: target
            )
        } else {
            return UITargetedDragPreview(
                view: textPreview,
                parameters: UIDragPreviewParameters(),
                target: target
            )
        }
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        
        if let selectedText = textView.text(in: dragRequest.dragRange) {
            /// UITextRange를 NSRange로 변경
            let startOffset: Int = textView.offset(
                from: textView.beginningOfDocument,
                to: dragRequest.dragRange.start
            )
            let endOffset: Int = textView.offset(
                from: textDraggableView.beginningOfDocument,
                to: dragRequest.dragRange.end
            )
            let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)
            let substring = textView.attributedText.attributedSubstring(from: offsetRange)
            
            if let attachment = substring.attributes(
                at: 0,
                effectiveRange: nil
            )[NSAttributedString.Key.attachment] as? NSTextAttachment {
                ///선택된 것이 이미지인 경우
                imagePreview.image = attachment.image
                isImageSelected = true
            } else {
                ///선택된 것이 텍스트인 경우
                previewLabel.text = selectedText
            }
            
            let itemProvider = NSItemProvider(object: selectedText as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        } else {
            return []
        }
    }
}

extension EntryViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        if !isBottom {
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
            let gesture = UIPanGestureRecognizer(
                target: self,
                action: #selector(didDrag(gestureRecognizer:))
            )
            bottomTableView.isScrollEnabled = false
            bottomTableView.addGestureRecognizer(gesture)
            changeBottomTableViewConstraints()
        }
    }
}

extension EntryViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named: customPointAnnotation.imageName)
        
        return annotationView
    }
}
