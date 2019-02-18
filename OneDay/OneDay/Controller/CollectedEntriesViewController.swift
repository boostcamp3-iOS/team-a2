//
//  CollectedEntriesViewController.swift
//  OneDay
//
//  Created by 정화 on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import MapKit
import UIKit

class CollectedEntriesViewController: UIViewController {
    let topFloatingView: UIView = {
        let view = UIView()
        view.backgroundColor = .doBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.backgroundColor = .doLight
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var entriesData = [Entry]()
    var shouldPresentMapView = false
    let headerMapView = CollectedEntriesHeaderMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .doBlue
        setupTableView()
        addLocationToMapView()
        doneButton.addTarget(
            self,
            action: #selector(dismissCollectedEntriesView),
            for: .touchUpInside)
    }

    @objc func dismissCollectedEntriesView() {
        dismiss(animated: false, completion: nil)
    }
    
    var coordinates: [MapPinLocation] = []
    var latitude = [CLLocationDegrees]()
    var longitude = [CLLocationDegrees]()

    fileprivate func addLocationToMapView() {
        entriesData.forEach { entry in
            if let location = entry.location {
                shouldPresentMapView = true
                
                coordinates.append(
                    MapPinLocation(
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude)))
            }
        }
    }
}

extension CollectedEntriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entriesData.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "listCellId",
            for: indexPath)
            as? CollectedEntriesListCell
        else {
            preconditionFailure("CollectedEntriesListCell Error")
        }
        
        let data = entriesData[indexPath.row]
        let attributedText = NSMutableAttributedString()
        setupAttributeText(data: data, text: attributedText)
        resizeImageAttachment(in: attributedText)

        cell.contentsListTextView.attributedText = attributedText
        return cell
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let mapViewHeight = UIScreen.main.bounds.height*0.4
        if shouldPresentMapView {
            return mapViewHeight
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let initialLocation = averageLocationOfCoordinates()
        var regionRadiusOnMap = mapViewPresentingRange(from: initialLocation, scale: 0.5)
        if regionRadiusOnMap < 5000 {
            regionRadiusOnMap = 5000 // 최소 5km 반경까지 지도가 그려짐
        }
        headerMapView.bind(
            coordinates: coordinates,
            initialLocation: initialLocation,
            regionRadius: regionRadiusOnMap)
        return headerMapView
    }
}

extension CollectedEntriesViewController {
    func setupAttributeText(data: Entry, text attributedText: NSMutableAttributedString) {
        if let contents = data.contents {
            attributedText.append(NSMutableAttributedString(attributedString: contents))
        }
        
        attributedText.append(NSMutableAttributedString(string: "\n\n"))

        if let title = data.journal?.title {
            attributedText.append(NSMutableAttributedString(string: title, attributes:[
                NSAttributedString.Key.foregroundColor : UIColor.doBlue,
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]))
        }
        
        let formatter = DateFormatter.defualtInstance
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YYYY년 MM월 dd일 EEEE a hh:mm"
        
        appendDot(at: attributedText)
        attributedText.append(NSMutableAttributedString(string: formatter.string(from: data.date)))
        
        if let address = data.location?.address {
            appendDot(at: attributedText)
            attributedText.append(NSMutableAttributedString(string: address))
        }
        
        if let temparature = data.weather?.tempature, let type = data.weather?.type {
            appendDot(at: attributedText)
            attributedText.append(NSMutableAttributedString(string: "\(temparature) °C  "))
            attributedText.append(NSMutableAttributedString(string: type))
        }
    }
    
    func resizeImageAttachment(in attributedText: NSMutableAttributedString) {
        attributedText.enumerateAttribute(
            NSAttributedString.Key.attachment,
            in: NSRange(location: 0, length: attributedText.length),
            options: [],
            using: { value, range, _ -> Void in
                if value is NSTextAttachment {
                    guard let attachment: NSTextAttachment = value as? NSTextAttachment
                        else {return}
                    
                    if let oldImage = attachment.image {
                        var newImage = UIImage()
                        newImage = oldImage
                        let imageWidth = UIScreen.main.bounds.width - 124
                        
                        let newAttachment: NSTextAttachment = NSTextAttachment()
                        newAttachment.image = newImage.resizeImageToFit(newWidth: imageWidth)
                        attributedText.replaceCharacters(
                            in: range,
                            with: NSAttributedString(attachment: newAttachment))
                    }
                }
        })
    }
    
    func appendDot(at attributedString: NSMutableAttributedString) {
        attributedString.append(
            NSMutableAttributedString(
                string: " · ",
                attributes: [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]))
    }
    
    fileprivate func setupTableView() {
        view.addSubview(topFloatingView)
        topFloatingView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topFloatingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topFloatingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topFloatingView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        topFloatingView.addSubview(dateLabel)
        dateLabel.leftAnchor.constraint(equalTo: topFloatingView.leftAnchor,
                                        constant: 24).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: topFloatingView.centerYAnchor).isActive = true

        topFloatingView.addSubview(doneButton)
        doneButton.rightAnchor.constraint(equalTo: topFloatingView.rightAnchor,
                                          constant: -24).isActive = true
        doneButton.centerYAnchor.constraint(equalTo: topFloatingView.centerYAnchor).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: topFloatingView.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.register(CollectedEntriesListCell.self, forCellReuseIdentifier: "listCellId")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//FIXME: 함수 다시 확인하기
extension CollectedEntriesViewController {
    func averageLocationOfCoordinates() -> CLLocation {
        coordinates.forEach { coordinates in
            latitude.append(coordinates.coordinate.latitude)
            longitude.append(coordinates.coordinate.longitude)
        }

        let averageLatitude = latitude.reduce(0, +) / Double(latitude.count)
        let averagelongitude = longitude.reduce(0, +) / Double(longitude.count)
//        let averageLocation = CLLocation(latitude: averageLatitude, longitude: averagelongitude)

        let averageLocation = CLLocation(latitude: latitude.first ?? 0, longitude: longitude.first ?? 0)
        return averageLocation
    }
    
    func mapViewPresentingRange(from averageLocation: CLLocation, scale: Double) -> Double {
        var distanceFromAverageLocation = [Double]()
        for index in 0..<latitude.count {
            distanceFromAverageLocation.append(
                averageLocation.distance(
                    from: CLLocation(
                        latitude: latitude[index],
                        longitude: longitude[index])))
        }
        guard let mapPresentingRange = distanceFromAverageLocation.max()
        else {
            preconditionFailure("Error")
        }
        return mapPresentingRange*scale
    }
}

extension UIImage {
    func resizeImageToFit(newWidth: CGFloat) -> UIImage {
        let size = self.size
        let ratio = size.height/size.width
        let newHeight = newWidth*ratio
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        self.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
}
