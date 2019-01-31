//
//  CalendarDaysOfWeek.swift
//  OneDay
//
//  Created by 정화 on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class CalendarDaysOfWeek: UIView {
    // 캘린더 탭 상단의 |일 월 화 수 목 금 토| 를 그리는 뷰
    let daysOfWeekView: UIStackView = {
        let stackView=UIStackView()
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints=false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CalendarDaysOfWeek {
    func setupView() {
        let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
        for index in 0..<7 {
            let label = UILabel()
            label.text = daysOfWeek[index]
            label.textAlignment = .center
            label.font = label.font.withSize(12)
            label.textColor = .black
            daysOfWeekView.addArrangedSubview(label)
        }

        addSubview(daysOfWeekView)
        daysOfWeekView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        daysOfWeekView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        daysOfWeekView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        daysOfWeekView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
}
