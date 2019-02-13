//
//  CalendarViewController.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

class CalendarViewController: UIViewController {
    
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
        let screenWidth = UIScreen.main.bounds.width
        flowLayout.itemSize = CGSize(width: screenWidth/7, height: screenWidth/7+10)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .doLight
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //  네비게이션 바 아래의 |일 월 화 수 목 금 토| 를 그리는 뷰
    let daysOfWeekView: CalendarDaysOfWeek = {
        let view = CalendarDaysOfWeek()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let datePicker = UIDatePicker()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.isLenient = true
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var fetchedEntriesDate = Set<String>()

    var isTodayIndex = false
    var isPickingDate = false
    var computedWeekday = 6
    
    override func viewDidLoad() {
        setupCoreData()
        setupCalendar()
        setupNavigationItem()
        setupSwipeGesture()
    }
    
    func setupCoreData() {
        let coreDataManager = CoreDataManager.shared
        let context = coreDataManager.managedContext
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            let entries = try context.fetch(fetchRequest)
            entries.forEach { (entry) in
                
                let date = entry.date
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day],
                                                         from: date ?? Date())
                if let year = components.year,
                    let month = components.month,
                    let day = components.day {
                    
                    let index = (year-1)*12+(month-1)
                    let path = "\(index)-\(day)"
                    fetchedEntriesDate.insert(path)
                }
            }
        } catch let fetchErr {
            print("Faild to fetch err \(fetchErr)")
        }
    }
    
    func setupSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDismiss))
        self.view.addGestureRecognizer(swipe)
    }
    
    func lastDayOfMonth(at section: Int) -> Int {
        var numberOfDaysOfMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let year = section/12+1
        let month = section%12+1
        
        if month==2 && ((year%4==0 && (year%100 != 0 || year%400==0)) || year%100==0 && year<1600) {
            numberOfDaysOfMonth[1] = 29 // 윤년
        }
        return section != 18981 ? numberOfDaysOfMonth[month-1] : 21 // 1582년 10월은 달력 문제
    }
    
    func firstWeekdayOfMonth(at section: Int) -> Int {
        let whatDate: String = "\(section/12+1)-\(section%12+1)-01"
        if let weekday = dateFormatter.date(from: whatDate) {
            return Calendar.current.component(.weekday, from: weekday)-1 // 0:일요일 ~ 6:토요일
        } else { preconditionFailure("Error") }
    }
    
    @objc func presentDatePicker() {
        setDatePicker()
    }
    
    @objc func pickDate() {
        isPickingDate = true
        collectionView.reloadData()
    }
    
    fileprivate func setupNavigationItem() {
        let pickerButton = UIButton(type: .custom)
        let calendarImage = UIImage(named: "navCalendar")?.withRenderingMode(.alwaysTemplate)
        pickerButton.setImage(calendarImage, for: .normal)
        pickerButton.tintColor = .white
        pickerButton.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: pickerButton)
        self.navigationItem.rightBarButtonItem = barButton  
    }
}

// MARK: 콜렉션뷰, CollectionVie
extension CalendarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        showActionSheet(indexPath.section, indexPath.item)
        datePicker.removeFromSuperview()
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            computedWeekday = 6
        }
        
        let numberOfDaysOfMonth = computedWeekday+lastDayOfMonth(at: section)

        computedWeekday = numberOfDaysOfMonth%7

        switch numberOfDaysOfMonth {
        case 1...28:
            return 28 // 7*4
        case 29...35:
            return 35 // 7*5
        default:
            return 42 // 7*6
        }
    }
    
    // 셀 아이템 정보 - 날짜 표시
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId",
                                                            for: indexPath) as? CalendarCell
        else {
            preconditionFailure("Error")
        }
        
        let sectionNumber = indexPath.section
        let day = indexPath.item+1-firstWeekdayOfMonth(at: sectionNumber)
        
        let checkEntriesTheDay = "\(sectionNumber)-\(day)"
        if fetchedEntriesDate.contains(checkEntriesTheDay) {
            cell.dayLabel.backgroundColor = .doBlue
            cell.dayLabel.textColor = .white
        }
        
        let numberOfDaysOfMonth = lastDayOfMonth(at: sectionNumber)
        if (1...numberOfDaysOfMonth).contains(day) {
        cell.isUserInteractionEnabled = true
        cell.dayLabel.text = "\(day)"
        } else {
        cell.isUserInteractionEnabled = false
        cell.dayLabel.backgroundColor = .calendarBackgroundColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if !isTodayIndex {     // 오늘의 인덱스에 해당하는 캘린더로 이동
            isTodayIndex = true
            
            let currentYear = Calendar.current.component(.year, from: Date())-1
            let currentMonth = Calendar.current.component(.month, from: Date())-1
            let currentDay = Calendar.current.component(.day, from: Date())

            let currentIndex = 12*(currentYear)+(currentMonth)
            collectionView.scrollToItem(at: [currentIndex, currentDay],
                                        at: .centeredVertically,
                                        animated: false)
        }
        
        if isPickingDate {     // 데이트피커에서 선택한 날로 이동
            isPickingDate = false
            let components = dateFormatter
                .string(from: datePicker.date)
                .split {$0 == "-"}
                .map {Int($0) ?? -1}
            
            let pickedIndex = (components[0]-1)*12+components[1]-1
            let pickedDay = components[2]
            
            collectionView.scrollToItem(at: [pickedIndex, pickedDay],
                                        at: .centeredVertically,
                                        animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12*3000
    }
    
    // MARK: Supplementary View
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
                                            ofKind: kind,
                                            withReuseIdentifier: "headerId",
                                            for: indexPath) as? CalendarHeaderView
        else {
            preconditionFailure("Error")
        }
        
        header.headerLabel.text = "\(indexPath.section/12+1)년 \(indexPath.section%12+1)월"
        return header
    }
}

extension CalendarViewController {
    func setupCalendar() {
        view.backgroundColor = .white
        view.addSubview(daysOfWeekView)
        daysOfWeekView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        daysOfWeekView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        daysOfWeekView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        daysOfWeekView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: daysOfWeekView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.register(CalendarCell.self,
                                forCellWithReuseIdentifier: "cellId")
        collectionView.register(CalendarHeaderView.self,
                                forSupplementaryViewOfKind:
                                UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "headerId")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func setDatePicker() {
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        datePicker.addTarget(self, action: #selector(pickDate), for: .valueChanged)
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 900, to: Date())
    }
}

// MARK: 액션시트, ActionSheet
extension CalendarViewController {
    func showActionSheet(_ section: Int, _ day: Int) {
        let date = dateComponents(section, item: day)
        let list = ["일", "월", "화", "수", "목", "금", "토"]
        let weekday = list[date.weekday!-1]
        
        let alertTitle = "\(date.year!)년 \(date.month!)월 \(date.day!)일 \(weekday)요일"
        let dayAlertController = UIAlertController(title: alertTitle,
                                                   message: nil,
                                                   preferredStyle: .actionSheet)
        
        let new = UIAlertAction(title: "새 엔트리 만들기", style: .default) { (_) in
            
        }
        
        let todayTitle = "\(date.year!). \(date.month!). \(date.day!). (1111 entries)"
        let today = UIAlertAction(title: todayTitle, style: .default) { (_) in

        }
        
        let yearTitle = "\(date.month!)월 \(date.day!)일 (1111 entries)"
        let year = UIAlertAction(title: yearTitle, style: .default) { (_) in
            
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        for sheet in [new, today, year, cancel] { dayAlertController.addAction(sheet) }
        present(dayAlertController, animated: false)
    }
    
    func dateComponents(_ section: Int, item: Int) -> DateComponents {
        let day = item+1-firstWeekdayOfMonth(at: section)
        let conmputedDate = "\(section/12+1)-\(section%12+1)-\(day)"
        let date = dateFormatter.date(from: conmputedDate)
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday],
                                                         from: date ?? Date())
        return components
    }
}
