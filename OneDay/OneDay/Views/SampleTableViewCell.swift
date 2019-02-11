//
//  SampleTableViewCell.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var jornalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    
    func bind(entry: Entry) {
        contentLabel.text = entry.title
        //        jornalLabel.text = entry.journal.title
        jornalLabel.text = "저널이름"
        
        let dateSet = DateStringSet(date: entry.date)
        timeLabel.text = dateSet.time
        dayLabel.text = dateSet.day
        weekDayLabel.text = dateSet.weekDay
        
    }
}
