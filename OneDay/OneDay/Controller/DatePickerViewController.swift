//
//  DatePickerViewController.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 18..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    var date: Date!
    let dateLabel = UILabel()
    let datePicker = UIDatePicker()
    let customSegmentedControl = UISegmentedControl(items: ["Date", "Time"])
    let currentDateButton = UIButton(type: UIButton.ButtonType.system)
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko-KR")
        formatter.dateFormat = "YYYY년 MM월 dd일, a h:mm"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setUpDateLabel()
        setUpSegmentControl()
        setUpDatePicker()
        setUpCurrentDateButton()
    }
    
    func setUpDateLabel() {
        dateLabel.text = dateFormatter.string(from: date)
        view.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dateLabel.textAlignment = .center
    }
    
    func setUpSegmentControl() {
        customSegmentedControl.selectedSegmentIndex = 0
        customSegmentedControl.tintColor = UIColor.doBlue
        customSegmentedControl.addTarget(
            self,
            action: #selector(changeDatePockerMode(sender:)),
            for: .valueChanged
        )
        view.addSubview(customSegmentedControl)
        customSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        customSegmentedControl.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        customSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        customSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        customSegmentedControl.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setUpDatePicker() {
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.setDate(date, animated: false)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: customSegmentedControl.bottomAnchor, constant: 8).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setUpCurrentDateButton() {
        currentDateButton.setTitle("현재 날짜/시간으로 설정", for: .normal)
        currentDateButton.setTitleColor(UIColor.black, for: .normal)
        currentDateButton.addTarget(
            self,
            action: #selector(setDateToCurrentDate(sender:)),
            for: .touchUpInside
        )
        view.addSubview(currentDateButton)
        currentDateButton.translatesAutoresizingMaskIntoConstraints = false
        currentDateButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor).isActive = true
        currentDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        currentDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        currentDateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
    }
    
    @objc func changeDatePockerMode(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            datePicker.datePickerMode = .time
        default:
            datePicker.datePickerMode = .date
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate: String = dateFormatter.string(from: sender.date)
        self.dateLabel.text = selectedDate
    }
    
    @objc func setDateToCurrentDate(sender: UIButton) {
        date = Date()
        let selectedDate: String = dateFormatter.string(from: date)
        self.dateLabel.text = selectedDate
        datePicker.setDate(date, animated: true)
    }
}
