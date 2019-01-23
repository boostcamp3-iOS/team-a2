//
//  FeedTableViewCell.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var jornalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!

    func bind(entry: Entry) {
        contentLabel.text = entry.title
        jornalLabel.text = entry.journal.title

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        timeLabel.text = dateFormatter.string(from: entry.date)

        dateFormatter.dateFormat = "d"
        dateLabel.text = dateFormatter.string(from: entry.date)

        dateFormatter.dateFormat = "EEE"
        dayLabel.text = dateFormatter.string(from: entry.date)
    }
}
