//
//  MainTabBarViewController.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

    }

}
// MARK: UITabBarControllerDelegate
extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AddActionViewController.self) {
//            let actionVC = UIAlertController(title: "일기작성", message: nil, preferredStyle: .actionSheet)
//            actionVC.modalPresentationStyle = .overFullScreen
//            self.present(actionVC, animated: true, completion: nil)
            print("hello")
            return false
        }
        return true
    }

}

class AddActionViewController: UIViewController {
    
}
