//
//  TestViewController.swift
//  OneDay
//
//  Created by 정화 on 24/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
//테스트용
//Main.storyboard에서 뷰컨트롤러 연결 확인해볼 것
class TestViewController: UIViewController {
    
    let testLabel = UILabel()
    let toCalendarButton = UIButton()

    override func viewDidLoad() {
        print("TestViewController viewDidLoad")
        view.backgroundColor = .doBlue
        view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(swipeToSideMenu)))
        toCalendarButton.addTarget(self, action: #selector(presentToCalendar), for: .touchUpInside)
        setupTestView()
    }
    
    @objc func presentToCalendar() {
        print("toCalendarButton clicked")
        present(CalendarViewController(), animated: false, completion: nil)
    }
}

extension TestViewController {
    func setupTestView() {
        view.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        testLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        testLabel.text = "slmfndfl;asfnslakfjsflksjl;kfajfl;ksdjfsl;fkjsfl;ksfjsafl;ajsls;afjsal;sdjl;ka;sdlfja;lsfj"
        testLabel.backgroundColor = .cyan
        
        view.addSubview(toCalendarButton)
        toCalendarButton.backgroundColor = .doLight
        toCalendarButton.setTitle("캘린더", for: .normal)
        toCalendarButton.setTitleColor(.black, for: .normal)
        toCalendarButton.translatesAutoresizingMaskIntoConstraints = false
        toCalendarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toCalendarButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200).isActive = true
        toCalendarButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        toCalendarButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
