//
//  FilterResultViewController.swift
//  OneDay
//
//  Created by juhee on 20/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

///  FilterResultViewController 필터 선택 후 결과 화면
class FilterResultViewController: UIViewController {
    
    // MARK: Properties
    
    // delegate Properties
    private weak var delegate: FilterViewControllerDelegate?
    
    private let reusableIdentifier: String = "filter_result_cell"
    private var filterType: FilterType!
    private var filtersArray: [(filter: Any, entries: [Entry])] = []
    
    private func filterDataTitle(data: Any) -> String {
        guard let filterType = filterType else { preconditionFailure() }
        var title: String?
        switch filterType {
        case .favorite:
            ()
        case .location:
            if let data = data as? Location {
                title = data.address
            }
        case .weather:
            if let data = data as? GroupedWeather {
                title = data.type
            }
        case .device:
            if let data = data as? Device {
                title = data.name
            }
        }
        return title ?? filterType.title
    }

    func bind(type: FilterType, data: [Any], delegator: FilterViewControllerDelegate?) {
        self.filterType = type
        self.delegate = delegator
        
        switch type {
        case .favorite:
            ()
        case .location:
            guard let data = data as? [Location] else { return }
            data.forEach { location in
                guard let address = location.address else { return }
                let data = CoreDataManager.shared.filter(by: [.currentJournal, .location(address: address)])
                filtersArray.append((filter: location, entries: data))
            }
        case .weather:
            guard let data = data as? [GroupedWeather] else { return }
            data.forEach { weather in
                let data = CoreDataManager.shared.filter(by: [.currentJournal, .weather(weatherType: weather.type)])
                filtersArray.append((filter: weather, entries: data))
            }
        case .device:
            guard let data = data as? [Device] else { return }
            data.forEach { device in
                guard let deviceId = device.deviceId else { return }
                let data = CoreDataManager.shared.filter(by: [.currentJournal, .device(deviceId: deviceId)])
                filtersArray.append((filter: device, entries: data))
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension FilterResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath) as? FilterResultTableViewCell else {
            preconditionFailure("dequeueReusableCell fail for \(indexPath) as FilterResultTableViewCell")
        }
        let filterData = filtersArray[indexPath.row]
        cell.bind(type: filterType, data: filterData.filter, count: filterData.entries.count)
        return cell
    }
}

extension FilterResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let filterData = filtersArray[indexPath.row]
        delegate?.presentCollectedEntries(for: filterData.entries, title: filterDataTitle(data: filterData.filter))
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filterType.title
    }
}
