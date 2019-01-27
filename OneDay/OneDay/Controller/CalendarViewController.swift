//
//  CalendarViewController.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

//FIXME: 개발하다가 든 생각 - 뷰만 만들어놓고, 년/월/일/요일 데이터를 데이터베이스에 넣어 주는게 빠르지 않을까...?...ㅜ
/* 캘린더
 1. 캘린더는 다음과 같이 만들어졌다.
 2. 0001년 01월을 0으로 한달이 지날때마다 1씩 올려서(1년 2월은 2, 2019년 1월은 2019*12+1), 오늘이 속하는 currentIndex를 구한다. 따라서 첫 번째 섹션은 01년 1월을, 두 번째 섹션은 01년 1월을, 2019*12+1번째 섹션은 19년 1월이 된다.
 3. 첫 화면에 오늘에 해당하는 인덱스의 캘린더를 가져온다.
 */
import UIKit

class CalendarViewController: UIViewController {
    // 3-1. 오늘 날짜에 해당하는 캘린더가 화면에 띄워져 있는가
    var isTodayIndex = false
    
    // 2-1. 오늘 날짜에 해당하는 인덱스 번호
    var currentIndex = 0
    override func viewDidLoad() {
        print("CalendarViewController viewDidLoad")
        view.backgroundColor = .white
        calCurrentIndex()
        setupCalendar()
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(dismissFromViewController)))
    }
    
    // 2-2. 0001년 01월일때 currentIndex = 0 으로 두고 이번달 인덱스를 역산한다.
    func calCurrentIndex() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        currentIndex = 12*(currentYear-1)+(currentMonth-1)
    }
    
    //윤년이면 true를 반환
    func checkLeap(year: Int) -> Bool {
        return year%4==0&&(year%100 != 0 || year%400 == 0) ? true : false
    }
    
    // 31/30/28/29 월말일 구하기
    func getEndDayOfMonth(from index: Int) -> Int {
        switch index%12+1 {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 2:
            return checkLeap(year: index/12+1) ? 29 : 28
        default:
            return 30
        }
    }
    
    // ****년 **월 01일이 무슨 요일인지 구하기 0:일, 1:화 ... 6:토
    // [.weekday]로 얻는 값의 범위는 1-7이지만, 셀 인덱스에 매칭하기 위해 -1을 해줌
    func getFirstWeekdayOfMonth(from index: Int) -> Int {
        let whatDay: String = "\(index/12+1)-\(index%12+1)-01"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let weekday = dateFormatter.date(from: whatDay) {
            return Calendar.current.component(.weekday, from: weekday)-1
        } else {
            preconditionFailure("getFirstWeekdayOfMonth 함수에서 에러 발생")
        }
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //FIXME: 성능 문제 - 로딩이 너무 오래걸림, GCD 다음에 시도
//                let rowsInMonth = getEndDayOfMonth(from: section) + getFirstWeekdayOfMonth(from: section)
//                switch rowsInMonth {
//                case 28:
//                    return 28
//                case 29...37:
//                    return 35
//                default:
//                    return 42
//            }
        return 42
    }
    // 셀 아이템 정보 - 날짜 표시
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? CalendarCell
            else { preconditionFailure("CalendarCell Error") }
        let firstWeekday = getFirstWeekdayOfMonth(from: indexPath[0])
        let endDay = getEndDayOfMonth(from: indexPath[0])

        if indexPath[1]+1-firstWeekday>0 && indexPath[1]-endDay-firstWeekday<0 {
            cell.dayLabel.text = "\(indexPath[1]+1-firstWeekday)"
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12*3000 // 0001년01월 ~ 3000년12월
    }
    
    // 셀 헤더 - ex: 2019년 01월
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as? CalendarHeaderView
            else { preconditionFailure("CalendarHeaderView Error") }
        header.headerLabel.text = "\(indexPath[0]/12+1)년 \(indexPath[0]%12+1)월"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    // 3-2 오늘의 인덱스에 해당하는 캘린더로 이동한다
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isTodayIndex {
            print("willDisplay")

            collectionView.scrollToItem(at: [currentIndex, 0], at: .centeredVertically, animated: false)
            isTodayIndex = true
        }
    }
}

extension CalendarViewController {
    func setupCalendar() {
//        캘린더 탭 상단의 |일 월 화 수 목 금 토| 를 그리는 뷰
        let daysOfWeekView: CalendarDaysOfWeek = {
            let view = CalendarDaysOfWeek()
            view.translatesAutoresizingMaskIntoConstraints=false
            return view
        }()
        
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
        
        view.addSubview(daysOfWeekView)
        daysOfWeekView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        daysOfWeekView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        daysOfWeekView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        daysOfWeekView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: daysOfWeekView.bottomAnchor, constant: 8).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(CalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
