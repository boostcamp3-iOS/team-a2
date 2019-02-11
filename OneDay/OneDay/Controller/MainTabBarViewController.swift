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
            let actionVC = UIAlertController(title: "일기작성", message: nil, preferredStyle: .actionSheet)
            actionVC.modalPresentationStyle = .overFullScreen
            // MARK :- FIXME
            
            actionVC.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: nil))
            actionVC.addAction(UIAlertAction(title: "카메라", style: .default, handler: nil))
            actionVC.addAction(UIAlertAction(title: "일기 쓰기", style: .default, handler: nil))
//            actionVC.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: { [weak self] _ in
//                let viewController = CreateEntryPhotosViewController()
//                self?.present(viewController, animated: true, completion: nil)
//            }))
//            actionVC.addAction(UIAlertAction(title: "카메라", style: .default, handler: { [weak self] _ in
//                let viewController = CreateEntryCameraViewController()
//                self?.present(viewController, animated: true, completion: nil)
//            }))
//            actionVC.addAction(UIAlertAction(title: "일기 쓰기", style: .default, handler: { [weak self] _ in
//                let viewController = EntryViewController()
//                self?.present(viewController, animated: true, completion: nil)
//            }))
            actionVC.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(actionVC, animated: true, completion: nil)
            return false
        }
        return true
    }

}

class AddActionViewController: UIViewController {
    
}
