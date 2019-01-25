//
//  TestViewController.swift
//  OneDayProto
//
//  Created by 정화 on 24/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
//테스트용
//Main.storyboard에서 뷰컨트롤러 연결 확인해볼 것
class TestViewController: UIViewController {

//    let sideMenuVC = SideMenuViewController()
    let testLabel = UILabel()
    override func viewDidLoad() {

        view.backgroundColor = .cyan
 self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(swipeToSideMenu)))
        setupTestLabel()
    }

}

extension TestViewController {
    func setupTestLabel() {
        view.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        testLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        testLabel.text = "slmfndfl;asfnslakfjsflksjl;kfajfl;ksdjfsl;fkjsfl;ksfjsafl;ajsls;afjsal;sdjl;ka;sdlfja;lsfj"
        testLabel.backgroundColor = .cyan
    }
}
