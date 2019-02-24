//
//  CalendarViewController.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import UIKit

/**
 CalendarViewController의 달력은 서기 1년 1월 1일부터 시작합니다.
 콜렉션 뷰이 섹션 하나가 하나의 연, 월에 해당하며, 서기 1년 1월은 섹션 0번, 2년 1월은 섹션 12번에 해당합니다.
 따라서, year = indexPath.section/12+1, month = indexPath.section%12+1로 표기 하였습니다.
 */
class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var calendarNavigationItem: UINavigationItem!
    
    private let collectionView: UICollectionView = {
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
    
    /// 네비게이션 바 아래의 |일 월 화 수 목 금 토| 를 그리는 뷰 입니다.
    private let daysOfWeekTitleView: CalendarDaysOfWeek = {
        let view = CalendarDaysOfWeek()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 900, to: Date())
        return picker
    }()
    
    // MARK: Variables

    private var isTodayIndex = false
    private var isPickingDate = false
    /**
     섹션 0번의 1년 1월 1일의 요일은 토요일입니다.
     본 달력에서는 각 요일(일~토)이 0~6의 숫자와 치환됩니다.
     */
    private var computedWeekday = 6
    
    private lazy var tabBarItemTouchCount = 0
    private lazy var isDatePikcerPresented = false

    private var fetchedEntriesDate = Set<String>()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        calendarNavigationItem.title = CoreDataManager.shared.currentJournal.title
        setupCalendar()
        setupNavigationItem()
        setupCoreData()
        
        addCoreDataChangedNotificationObserver()
        addEntriesFilterChangedNotificationObserver()
        addTabBarItemTouchingNotificationObserver()
    }
    
    // MARK: - CoreData
    
    /**
     캘린더에는 해당하는 날에 작성된 엔트리가 있는지를 색상 변화(파란색)를 통해 사용자에게 알려줍니다.
     캘린더에 표시하기 위해서 년, 월, 일별로 고유한 하나의 값만 필요하므로 현재 저널에 해당하는 엔트리의 날짜들을
     fetchedEntriesDate에 추가합니다.
     */
    private func setupCoreData() {
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
    
    private func setupNavigationItem() {
        let pickerButton = UIButton(type: .custom)
        let calendarImage = UIImage(named: "navCalendar")?.withRenderingMode(.alwaysTemplate)
        pickerButton.setImage(calendarImage, for: .normal)
        pickerButton.tintColor = .white
        pickerButton.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: pickerButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func presentDatePicker() {
        isDatePikcerPresented = true
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        datePicker.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -49).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        datePicker.addTarget(self, action: #selector(pickDate), for: .valueChanged)
    }
    
    @objc private func pickDate() {
        isPickingDate = true
        collectionView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isDatePikcerPresented {
            datePicker.removeFromSuperview()
            isDatePikcerPresented = false
        }
    }
    
    // MARK: - Calendar Function
    
    /**
    뷰에 표시되고 있는 섹션에 해당하는 연, 월의 마지막 날이 며칠인지를 계산하고 반환합니다.
     - 1600년 이전의 윤년 계산식이 현재와 다름에 유의하십시오.
     - 18981은 1582년 10월에 해당하는 섹션입니다. 이 달은 예외적으로 한 달이 21일입니다.
     자세한 사항은 인터넷 검색을 참조하십시오.
     
     - parameter section: 콜렉션 뷰의 섹션 번호
     - returns: 섹션에 해당하는 연, 월의 마지막 날

    */
    private func lastDayInMonth(at section: Int) -> Int {
        var numberOfDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let year = section/12+1
        let month = section%12+1
        
        if month == 2 &&
            ((year%4 == 0 && (year%100 != 0 || year%400 == 0)) ||
                year%100 == 0 && year<1600) {
            numberOfDaysInMonth[1] = 29 // 윤년
        }
        return section != 18981 ? numberOfDaysInMonth[month-1] : 21
    }
    
    /**
     뷰에 표시되고 있는 섹션에 해당하는 요일이 무엇인지를 계산하고 반환합니다.
     - 캘린더 컴포넌트의 .weekday는 1~7의 범위로 반환되지만,
     콜렉션 뷰의 아이템 인덱스에서 사용하기 위해 -1을 해준 것에 유의하십시오.
     
     - parameter section: 콜렉션 뷰의 섹션 번호
     - returns: 섹션에 해당하는 연, 월의 첫 날의 요일
     */
    private func firstWeekdayInMonth(at section: Int) -> Int {
        let components = DateComponents(year: section/12+1, month: section%12+1, day: 1)
        let date = Calendar.current.date(from: components)
        
        if let date = date {
            return Calendar.current.component(.weekday, from: date)-1
        } else {
            preconditionFailure("Error")
        }
    }
    
    // MARK: - Notification
    
    private func addCoreDataChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCoreDataChangedNotification(_:)),
            name: CoreDataManager.DidChangedCoreDataNotification,
            object: nil)
    }
    
    @objc private func didReceiveCoreDataChangedNotification(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func addEntriesFilterChangedNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEntriesFilterChangedNotification(_:)),
            name: CoreDataManager.DidChangedEntriesFilterNotification,
            object: nil)
    }
    
    @objc private func didEntriesFilterChangedNotification(_: Notification) {
        calendarNavigationItem.title = CoreDataManager.shared.currentJournal.title
        setupCoreData()
    }
    
    private func addTabBarItemTouchingNotificationObserver() {
        let scrollToTodayCalendar = Constants.tabBarItemTouchCountsNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(touchTabBarItem),
            name: scrollToTodayCalendar,
            object: nil)
    }
    
    @objc private func touchTabBarItem() {
        tabBarItemTouchCount += 1
        if tabBarItemTouchCount == 2 {
            tabBarItemTouchCount = 0
            scrollToDate(date: Date(), animated: false)
        }
    }
    
    private func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tabBarItemTouchCount = 0
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        
        showActionSheet(indexPath.section, indexPath.item)
        datePicker.removeFromSuperview()
        isDatePikcerPresented = false
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        
        if !isTodayIndex {     // 오늘의 인덱스에 해당하는 캘린더로 이동
            isTodayIndex = true
            scrollToDate(date: Date(), animated: false)
        } else if isPickingDate {     // 데이트피커에서 선택한 날로 이동
            isPickingDate = false
            scrollToDate(date: datePicker.date, animated: true)
        }
    }
    
    private func scrollToDate(date: Date, animated: Bool) {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date)
        if let year = components.year,
            let month = components.month,
            let day = components.day {
            
            let index = 12*(year-1)+(month-1)
            let day = day
            collectionView.scrollToItem(
                at: [index, day],
                at: .centeredVertically,
                animated: animated)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDataSource {
    /*
     섹션에 해당하는 연, 월의 첫 날에 해당하는 요일과,
     마지막 날을 합하여 달력을 몇 줄로 표현할 지 계산합니다.
     본 달력에서는 일주일을 일~토요일으로 표현하고 있기 때문에 콜렉션의 한 줄은 7개의 셀입니다.
     따라서 반환값 28은 4줄, 35는 5줄, 42는 6줄로 달력이 그려지게 됩니다.
     - parameter section: 콜렉션 뷰의 섹션 넘버
     - returns: 섹션에 그려야 하는 셀의 갯수
     */
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        if section == 0 {
            computedWeekday = 6
        }
        
        let numberOfCellsInMonth = computedWeekday+lastDayInMonth(at: section)
        computedWeekday = numberOfCellsInMonth%7
        switch numberOfCellsInMonth {
        case 1...28:
            return 28
        case 29...35:
            return 35
        default:
            return 42
        }
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
        
        /*
         달력의 첫 날을 요일에 따라 위치시키기 위해 dayNumber를 계산합니다.
         섹션에 해당하는 연, 월의 첫 날이 화요일(firstWeekdayInMonth == 2)이면 dayNumber는
         indexPath.item == 0:
         0+1-2= -1
         indexPath.item == 1:
         1+1-2= 0
         indexPath.item == 2:
         2+1-2= 1
         과 같이 계산되므로, indexPath.item이 2인 세 번째 셀에서 숫자 1을 표시합니다.
         */
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12*3000
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

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
}

// MARK: - Layout

extension CalendarViewController {
    private func setupCalendar() {
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

// MARK: ActionSheet

extension CalendarViewController {
    private func showActionSheet(_ sectionNumber: Int, _ day: Int) {
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
    
    private func convertSectionNumberToDateComponents(_ section: Int, item: Int) -> DateComponents {
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
    
    private func addNewEntryAction(
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
                entryViewController.entry = CoreDataManager.shared.insert(type: Entry.self)
                entryViewController.entry.date = components.date ?? Date()
                entryViewController.entry.updateDate(date: components.date ?? Date())
                self.present(entryViewController, animated: true)
        })
    }
    
    private func addTodayEntryAction(
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
    
    private func addYearEntryAction(
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
