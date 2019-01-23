//
//  FeedViewController.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreLocation

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTable: UITableView!
    var tempEntries: [Entry] = []

    private let cellIdentifier = "feed_cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tempDataSetting()

    }

    func tempDataSetting() {
        let journal = Journal.init(id: 0, title: "일지이", index: 0, entryCount: 6, entries: [])

        (0...5).forEach { index in
            let entry = Entry.init(id: index, contents: [], updatedDate: Date(), date: Date(), isFavorite: false, journal: journal, location: nil, tags: ["태그1", "태그2"], deviceId: "1")
            tempEntries.append(entry)
        }
        feedTable.reloadData()
    }
}

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hello")
        return tempEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewCell else { return UITableViewCell() }

        cell.bind(entry: tempEntries[indexPath.row])
        return cell
    }
}
