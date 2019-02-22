//
//  MainTabBarViewController.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

/**
 메인 화면이 되는 TabBarController
 
 총 5개의 탭을 가지고 있으며 세번째 탭을 눌렀을 때는 AddViewController를 띄우지 않고 actionsheet를 연다.
 */
class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
        ) {
        selectedCalendarTab(tabBarController)
    }
    
    private func selectedCalendarTab(_ tabBarController: UITabBarController) {
        let scrollToTodayCalendar = Constants.tabBarItemTouchCountsNotification
        if tabBarController.selectedIndex == 4 {
            NotificationCenter.default.post(
                name: scrollToTodayCalendar,
                object: nil
            )
        }
    }
}

// MARK: UITabBarControllerDelegate
extension MainTabBarViewController: UITabBarControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func tabBarController
        (_ tabBarController: UITabBarController,
         shouldSelect viewController: UIViewController
        ) -> Bool {
        
        if viewController.isKind(of: AddActionViewController.self) {
            let actionViewController = UIAlertController(
                title: "일기작성",
                message: nil,
                preferredStyle: .actionSheet)
            actionViewController.modalPresentationStyle = .overFullScreen
            actionViewController.addAction(UIAlertAction(
                title: "사진 선택",
                style: .default,
                handler: { [weak self] _ in
                    self?.selectImage(from: .photoLibrary)
            }))
            actionViewController.addAction(UIAlertAction(
                title: "카메라",
                style: .default,
                handler: { [weak self] _ in
                    guard UIImagePickerController.isSourceTypeAvailable(.camera)
                        else {
                            self?.selectImage(from: .photoLibrary)
                            return
                    }
                    self?.selectImage(from: .camera)
            }))
            actionViewController.addAction(UIAlertAction(
                title: "일기 쓰기",
                style: .default,
                handler: { [weak self] _ in
                    guard let nextViewController = UIStoryboard(name: "Coredata", bundle: nil)
                        .instantiateViewController(withIdentifier: "entry_detail")
                        as? EntryViewController
                        else {
                            return
                    }
                    nextViewController.entry = CoreDataManager.shared.insertEntry()
                    self?.present(nextViewController, animated: true)
            }))
            actionViewController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(actionViewController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    /**
     이미지 피커에서 이미지 선택이 완료되었을 때 호출된다.
     picker를 내려주고 선택된 이미지를 받아서 Entry Contents에 담아서 EntryViewController로 이동하는 createEntryWithImage()를 호출한다.
     */
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
        picker.dismiss(animated: true, completion: nil)
        createEntryWithImage(pickingMediaWithInfo: info)
    }
}
