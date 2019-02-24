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
    private let topFloatingView: UIView = {
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
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
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
    /// 엔트리에 위치 정보가 있을 때만 맵 뷰를 보여줍니다.
    private var shouldPresentMapView = false
    private let headerMapView = CollectedEntriesHeaderMapView()
    private var entriesLocation: [MapPinLocation] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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

    /// 맵 어노테이션에 사용하기 위해 좌표를 배열에 추가합니다.
    private func addLocationToMapView() {
        entriesData.forEach { entry in
            if let location = entry.location {
                shouldPresentMapView = true
                entriesLocation.append(
                    MapPinLocation(
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude)))
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CollectedEntriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldPresentMapView {
            let mapViewHeight = UIScreen.main.bounds.height*0.4
            return mapViewHeight
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerMapView.bind(locations: entriesLocation)
        return headerMapView
    }
}

// MARK: - UITableViewDataSource

extension CollectedEntriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entriesData.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "listCellId",
            for: indexPath) as? CollectedEntriesListCell
        else { preconditionFailure("Error") }
        
        let entry = entriesData[indexPath.row]
        cell.bind(entry: entry)
        return cell
    }
}

extension CollectedEntriesViewController {
    private func setupTableView() {
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
