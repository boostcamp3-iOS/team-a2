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
    var willPresentMapView = false
    let headerMapView = CollectedEntriesHeaderMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .doBlue
        setupTableView()
        addLocationToMapView()
        doneButton.addTarget(self, action: #selector(backToCalendar), for: .touchUpInside)
    }

    @objc func backToCalendar() {
        dismiss(animated: false, completion: nil)
    }
    
    var coordinates: [MapPinLocation] = []
    var latitude = [CLLocationDegrees]()
    var longitude = [CLLocationDegrees]()
    
    fileprivate func addLocationToMapView() {
        entriesData.forEach { (entry) in
            if let location = entry.location {
                willPresentMapView = true
                
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
        
        cell.contentsListTextView.attributedText = attributedText
        return cell
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let mapViewHeight = UIScreen.main.bounds.height*0.4
        return willPresentMapView ? mapViewHeight : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let initialLocation = setInitialLocation()
        var regionRadiusOnMap = mapViewPresentingRange(from: initialLocation, scale: 3)
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
        formatter.locale = Locale(identifier: "ko-·")
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

extension CollectedEntriesViewController {
    func setInitialLocation() -> CLLocation {
        coordinates.forEach { (coordinates) in
            latitude.append(coordinates.coordinate.latitude)
            longitude.append(coordinates.coordinate.longitude)
        }
        
        let averageLatitude = latitude.reduce(0, +) / Double(latitude.count)
        let averagelongitude = longitude.reduce(0, +) / Double(longitude.count)
        
        let averageLocation = CLLocation(
            latitude: averageLatitude,
            longitude: averagelongitude)
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
