//
//  CalendarViewController.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    let datePicker = UIDatePicker()

    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .doLight
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.isLenient = true
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var isTodayIndex = false    // 오늘 날짜에 해당하는 캘린더가 화면에 띄워져 있는가
    var isPickingDate = false     // 데이트피커에서 선택되었는가
    var weekdayCheck = 6 // 월의 첫 요일이 무엇인지 계산
    
    var selectedDate: [Int] = [0, 0] { // 데이트 피커에서 선택된 날짜로 이동한다
        willSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setupCalendar()
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(dismissFromViewController)))
        fixMeSetNavigation()
    }
    
    //FIXME: 시간남으면 요일 계산한것처럼 Calendar 안쓰고 날짜 계산하기.
    func getDaysOfMonth(from index: Int) -> Int {
        let dateComponents = DateComponents(year: index/12+1, month: index%12+1)
        let date =  Calendar.current.date(from: dateComponents)!
        var count = Calendar.current.range(of: .day, in: .month, for: date)!.count
        if index == 18982 { count -= -11 } // 1582년 10월은 5일부터 14일이 존재하지 않음
        return count
    }
    
    func getFirstWeekdayOfMonth(from index: Int) -> Int {
        let whatDay: String = "\(index/12+1)-\(index%12+1)-01"
        if let weekday = dateFormatter.date(from: whatDay) {
            return Calendar.current.component(.weekday, from: weekday)-1
        } else { preconditionFailure("getFirstWeekdayOfMonth 함수에서 에러 발생") }
    }
    
    @objc func presentDatePicker() {
        setDatePicker()
    }
    
    @objc func pickedDate() {
        isPickingDate = true

        let dateItem = dateFormatter.string(from: datePicker.date).split {$0 == "-"}.map {Int($0) ?? -1}
        let indexPath: [Int] = [(dateItem[0]-1)*12+dateItem[1]-1, dateItem[2]]
        selectedDate = indexPath
    }
}

// MARK: 콜렉션뷰, CollectionVie
extension CalendarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showActionSheet(indexPath[0], day: indexPath[1])
        if isPickingDate {
            isPickingDate = false
            
            let centeredIndexPath = IndexPath.init(item: selectedDate[1], section: selectedDate[0])
            collectionView.scrollToItem(at: centeredIndexPath, at: .centeredVertically, animated: true)
            
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cal = weekdayCheck + getDaysOfMonth(from: section)
        weekdayCheck = cal % 7
        
            switch cal {
            case 28:
                return 28
            case 29...36:
                return 35
            default:
                return 42
        }
    }
    
    // 셀 아이템 정보 - 날짜 표시
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? CalendarCell
            else { preconditionFailure("CalendarCell Error") }
        
        let firstWeekday = getFirstWeekdayOfMonth(from: indexPath[0])
        let endDay = getDaysOfMonth(from: indexPath[0])
        
        if indexPath[1]+1-firstWeekday>0 && indexPath[1]-endDay-firstWeekday<0 {
            cell.dayLabel.text = "\(indexPath[1]+1-firstWeekday)"
        } else {
            cell.dayLabel.backgroundColor = .doLight
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isTodayIndex {     // 오늘의 인덱스에 해당하는 캘린더로 이동
            isTodayIndex = true
            
            let currentIndex = 12*(Calendar.current.component(.year, from: Date())-1)+(Calendar.current.component(.month, from: Date())-1)
            collectionView.scrollToItem(at: [currentIndex, 0], at: .centeredVertically, animated: false)
        }
        if isPickingDate {     // 데이트피커에서 선택한 날로 이동
            isPickingDate = false
            
            let dateItem = dateFormatter.string(from: datePicker.date).split {$0 == "-"}.map {Int($0) ?? -1}
            collectionView.scrollToItem(at: [(dateItem[0]-1)*12+dateItem[1]-1, dateItem[2]], at: .centeredVertically, animated: false)
        }
    }
    
    // MARK: Supplementary View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12*3000 // 0001년01월 ~ 3000년12월
    }
    
    // 셀 헤더 라벨 Supplementary View- ex: 2019년 01월
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as? CalendarHeaderView else { preconditionFailure("CalendarHeaderView Error") }
        
        header.headerLabel.text = "\(indexPath[0]/12+1)년 \(indexPath[0]%12+1)월"
        return header
    }
    
    // 셀 헤더 뷰
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { 
        return CGSize(width: view.frame.width, height: 35)
    }
}

extension CalendarViewController {
    func setupCalendar() {
        //        캘린더 탭 상단의 |일 월 화 수 목 금 토| 를 그리는 뷰
        let daysOfWeekView: CalendarDaysOfWeek = {
            let view = CalendarDaysOfWeek()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        view.addSubview(daysOfWeekView)
        daysOfWeekView.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
        daysOfWeekView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        daysOfWeekView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        daysOfWeekView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: daysOfWeekView.bottomAnchor, constant: 8).isActive = true
        //FIXME: 이따가 삭제
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(CalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func setDatePicker() {
        datePicker.addTarget(self, action: #selector(pickedDate), for: .valueChanged)
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 900, to: Date())
        view.addSubview(datePicker)
    }
}

//MARK: 액션시트, ActionSheet
extension CalendarViewController {
    func showActionSheet(_ index: Int, day: Int) {
        let date = getDateFrom(index, day: day)
        let list = ["일", "월", "화", "수", "목", "금", "토"]
        let weekday = list[date.weekday!-1]
        
        let dayAlertController = UIAlertController(title: "\(date.year!)년 \(date.month!)월 \(date.day!)일 \(weekday)요일", message: nil, preferredStyle: .actionSheet)
        
        let new = UIAlertAction(title: "새 엔트리 만들기", style: .default) { (_) in
            
        }
        let today = UIAlertAction(title: "\(date.year!). \(date.month!). \(date.day!). (1111 entries)", style: .default) { (_) in

        }
        let year = UIAlertAction(title: "\(date.month!)월 \(date.day!)일 (1111 entries)", style: .default) { (_) in
            
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        for sheet in [new, today, year, cancel] { dayAlertController.addAction(sheet) }
        present(dayAlertController, animated: false)
    }
    
    func getDateFrom(_ index: Int, day: Int) -> DateComponents {
        let translatedDay = day+1-getFirstWeekdayOfMonth(from: index)
        let date = dateFormatter.date(from: "\(index/12+1)-\(index%12+1)-\(translatedDay)")
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date ?? Date())
        return dateComponents
    }
}

// FIXME: 네비게이션 바 아이템 대용 > 네비게이션 생기면 전체 삭제
extension CalendarViewController {
    func fixMeSetNavigation() {
        let navRightButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .black
            button.setTitleColor(.white, for: .normal)
            button.setTitle("date picker", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        view.addSubview(navRightButton)
        navRightButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navRightButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navRightButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        navRightButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        navRightButton.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)
    }
}
