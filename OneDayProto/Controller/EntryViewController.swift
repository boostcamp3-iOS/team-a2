//
//  EntryViewController.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

class EntryViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var timeLabel: UILabel!

    var entry: EntryVO?
    weak var delegate: EntryDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        var dateSet: DateStringSet = DateStringSet(date: Date())
        if let data = entry {
            dateSet = DateStringSet(date: data.date)
//            contentField.text = data.contents.reduce("") { (result, contents) -> String in
//                return "\(result)\(contents.content)"
//            }
            contentField.text = data.title
        }

        dateLabel.text = dateSet.full
        timeLabel.text = dateSet.time
    }

    @IBAction func saveAndDismiss(_ sender: UIButton) {
        guard let content = contentField.text else {
            return
        }
        if let entry = entry {
            delegate.update(entry: entry)
        } else {
            let journal = Journal.init(id: 0, title: "일지이", index: 0, entryCount: 0, entries: [])

            let newEntry = EntryVO.init(id: 1, contents: [], updatedDate: Date(), date: Date(), isFavorite: false, journal: journal, location: nil, tags: ["태그1", "태그2"], deviceId: "1", title: content)

            delegate.register(new: newEntry)
        }

        dismiss(animated: true, completion: nil)
    }

}
