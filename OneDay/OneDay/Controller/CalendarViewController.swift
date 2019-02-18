//
//  CalendarViewController.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

class CalendarViewController: UIViewController, UITabBarControllerDelegate {
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
        let screenWidth = UIScreen.main.bounds.width
        flowLayout.itemSize = CGSize(width: screenWidth/7, height: screenWidth/7+10)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .doLight
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //  네비게이션 바 아래의 |일 월 화 수 목 금 토| 를 그리는 뷰
    let daysOfWeekTitleView: CalendarDaysOfWeek = {
        let view = CalendarDaysOfWeek()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 900, to: Date())
        return picker
    }()
    
    fileprivate var isTodayIndex = false
    fileprivate var isPickingDate = false
    fileprivate var computedWeekday = 6
    lazy var tappingTabItemCount = 0

    var fetchedEntriesDate = Set<String>()

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        setupCalendar()
        setupNavigationItem()
        setupCoreData()
        
        addCoreDataChangedNotificationObserver()
        
        tabBarController?.delegate = self
        tappingTabItemCount = 0
    }
    
    // MARK: - CoreData

    fileprivate func setupCoreData() {
        fetchedEntriesDate = []
        let entriesData = CoreDataManager.shared.currentJournalEntries
        entriesData.forEach { (entry) in
            let date = entry.date
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            if let year = components.year,
                let month = components.month,
                let day = components.day {
                    let date = "\(year)\(month)\(day)"
                    fetchedEntriesDate.insert(date)
            }
        }
    }
    
    // MARK: - NavigationItem: DatePicker
    
    fileprivate func setupNavigationItem() {
        let pickerButton = UIButton(type: .custom)
        let calendarImage = UIImage(named: "navCalendar")?.withRenderingMode(.alwaysTemplate)
        pickerButton.setImage(calendarImage, for: .normal)
        pickerButton.tintColor = .white
        pickerButton.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: pickerButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func presentDatePicker() {
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        datePicker.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -49).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        datePicker.addTarget(self, action: #selector(pickDate), for: .valueChanged)
    }
    
    @objc func pickDate() {
        isPickingDate = true
        collectionView.reloadData()
    }
    
    // MARK: - Calendar Function
    
    fileprivate func lastDayInMonth(at section: Int) -> Int {
        var numberOfDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let year = section/12+1
        let month = section%12+1
        
        if month == 2 &&
            ((year%4 == 0 && (year%100 != 0 || year%400 == 0)) ||
                year%100 == 0 && year<1600) {
            numberOfDaysInMonth[1] = 29 // 윤년
        }
        return section != 18981 ? numberOfDaysInMonth[month-1] : 21 // 1582년 10월 달력 문제
    }
    
    fileprivate func firstWeekdayInMonth(at section: Int) -> Int {
        let components = DateComponents(year: section/12+1, month: section%12+1, day: 1)
        let date = Calendar.current.date(from: components)

        if let date = date {
            return Calendar.current.component(.weekday, from: date)-1 // 0:일요일 ~ 6:토요일
        } else {
            preconditionFailure("Error")
        }
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController) {
        tappingTabItemCount += 1
        if tappingTabItemCount == 2 {
            tappingTabItemCount = 0
            scrollToDate(date: Date(), animated: false)
        }
    }
    
    // MARK: - Notification
    
    func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoredDataNotification,
            object: nil)
    }
    
    @objc func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.setupCoreData()
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - 콜렉션뷰, CollectionView

extension CalendarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        if section == 0 {
            computedWeekday = 6
        }
        
        let numberOfDaysOfMonth = computedWeekday+lastDayInMonth(at: section)
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        
        showActionSheet(indexPath.section, indexPath.item)
        datePicker.removeFromSuperview()
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cellId",
            for: indexPath
            ) as? CalendarCell
        else {
            preconditionFailure("Error")
        }
        
        let sectionNumber = indexPath.section
        let dayNumber = indexPath.item+1-firstWeekdayInMonth(at: sectionNumber)
        
        let numberOfDaysOfMonth = lastDayInMonth(at: sectionNumber)
        if (1...numberOfDaysOfMonth).contains(dayNumber) {
            cell.isUserInteractionEnabled = true
            cell.dayLabel.text = "\(dayNumber)"
        } else {
            cell.isUserInteractionEnabled = false
            cell.dayLabel.backgroundColor = .calendarBackgroundColor
        }
        
        let entryWritingDay = "\(sectionNumber/12+1)\(sectionNumber%12+1)\(dayNumber)"
        if fetchedEntriesDate.contains(entryWritingDay) {
            cell.dayLabel.backgroundColor = .doBlue
            cell.dayLabel.textColor = .white
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        
        if !isTodayIndex {     // 오늘의 인덱스에 해당하는 캘린더로 이동
            isTodayIndex = true
            scrollToDate(date: Date(), animated: false)
        }
        
        if isPickingDate {     // 데이트피커에서 선택한 날로 이동
            isPickingDate = false
             scrollToDate(date: datePicker.date, animated: true)
        }
    }
    
    func scrollToDate(date: Date, animated: Bool) {
        let components = Calendar.current.dateComponents([.year, .month, .day],
                                                         from: date)
        if let year = components.year,
            let month = components.month,
            let day = components.day {
            
            let index = 12*(year-1)+(month-1)
            let day = day
            collectionView.scrollToItem(at: [index, day],
                                        at: .centeredVertically,
                                        animated: animated)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12*3000
    }
    
    // MARK: - Supplementary View
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerId",
            for: indexPath
            ) as? CalendarHeaderView
        else {
            preconditionFailure("Error")
        }
        
        let year = indexPath.section/12+1
        let month = indexPath.section%12+1
        header.headerLabel.text = "\(year)년 \(month)월"
        return header
    }
}

extension CalendarViewController {
    fileprivate func setupCalendar() {
        view.backgroundColor = .white
        
        view.addSubview(daysOfWeekTitleView)
        daysOfWeekTitleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        daysOfWeekTitleView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        daysOfWeekTitleView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        daysOfWeekTitleView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(
            equalTo: daysOfWeekTitleView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.register(
            CalendarCell.self,
            forCellWithReuseIdentifier: "cellId")
        collectionView.register(
            CalendarHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerId")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: 액션시트, ActionSheet

extension CalendarViewController {
    func showActionSheet(_ sectionNumber: Int, _ day: Int) {
        let date = convertSectionNumberToDateComponents(sectionNumber, item: day)
        let list = ["일", "월", "화", "수", "목", "금", "토"]
        let weekday = list[date.weekday!-1]
        guard let year = date.year, let month = date.month, let day = date.day else { return }
        
        let entriesAtDay = CoreDataManager.shared.filter(
            by:[.thisYear(year: year),
                .thisDay(month: month, day: day)])
        let entriesOnThisDay = CoreDataManager.shared.filter(
            by: [.thisDay(month: month, day: day)])
        
        let alertTitle = "\(year)년 \(month)월 \(day)일 \(weekday)요일"
        let dayAlertController = UIAlertController(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet)
        
        addNewEntryAction(date: year, month, day, to: dayAlertController)
        
        if !entriesAtDay.isEmpty {
            addTodayEntryAction(date: year, month, day, weekday, about: entriesAtDay, to: dayAlertController)
            addYearEntryAction(date: month, day, about: entriesOnThisDay, to: dayAlertController)
        }
        dayAlertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(dayAlertController, animated: false)
    }
    
    fileprivate func convertSectionNumberToDateComponents(_ section: Int, item: Int) -> DateComponents {
        let selectedDay = item+1-firstWeekdayInMonth(at: section)
        let components = DateComponents(year: section/12+1, month: section%12+1, day: selectedDay)
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            let componentsWithWeekday = calendar.dateComponents(
                [.year, .month, .day, .weekday],
                from: date)
            return componentsWithWeekday
        } else {
            preconditionFailure("Error")
        }
    }
    
    fileprivate func addNewEntryAction(
        date year: Int,
        _ month: Int,
        _ day: Int,
        to calendarCellAlertController: UIAlertController) {
        calendarCellAlertController.addAction(UIAlertAction(
            title: "새 엔트리 만들기",
            style: .default) { (_) in
                let components = DateComponents(
                    calendar: Calendar.current,
                    year: year,
                    month: month,
                    day: day)
                
                guard let entryViewController = UIStoryboard(name: "Coredata", bundle: nil)
                    .instantiateViewController(withIdentifier: "entry_detail")
                    as? EntryViewController
                    else { return }
                entryViewController.entry = CoreDataManager.shared.insertEntry()
                entryViewController.entry.date = components.date ?? Date()
                entryViewController.entry.updateDate(date: components.date ?? Date())
                self.present(entryViewController, animated: true)
        })
    }
    
    fileprivate func addTodayEntryAction(
        date year: Int,
        _ month: Int,
        _ day: Int,
        _ weekday: String,
        about entriesAtDay: [Entry],
        to dayAlertController: UIAlertController) {
        let todayAlertTitle = "\(year). \(month). \(day). (\(entriesAtDay.count) entries)"
        let todayAlert = UIAlertAction(
            title: todayAlertTitle,
            style: .default) { (_) in
                let collectedEntriesViewController = CollectedEntriesViewController()
                collectedEntriesViewController.dateLabel.text =
                "\(year)년 \(month)월 \(day)일 \(weekday)요일"
                collectedEntriesViewController.entriesData = entriesAtDay
                self.present(collectedEntriesViewController, animated: true, completion: nil)
        }
        dayAlertController.addAction(todayAlert)
    }
    
    fileprivate func addYearEntryAction(
        date month: Int,
        _ day: Int,
        about entriesOnThisDay: [Entry],
        to dayAlertController: UIAlertController) {
        let yearAlertTitle = "\(month)월 \(day)일 (\(entriesOnThisDay.count) entries)"
        let yearAlert = UIAlertAction(
            title: yearAlertTitle,
            style: .default) { (_) in
                let collectedEntriesViewController = CollectedEntriesViewController()
                collectedEntriesViewController.dateLabel.text = "\(month)월 \(day)일"
                collectedEntriesViewController.entriesData = entriesOnThisDay
                self.present(collectedEntriesViewController, animated: true, completion: nil)
        }
        dayAlertController.addAction(yearAlert)
    }
}
