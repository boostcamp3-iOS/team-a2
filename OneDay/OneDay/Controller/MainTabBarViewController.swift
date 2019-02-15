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
extension MainTabBarViewController: UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AddActionViewController.self) {
            let actionVC = UIAlertController(title: "일기작성", message: nil, preferredStyle: .actionSheet)
            actionVC.modalPresentationStyle = .overFullScreen
            actionVC.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: { [weak self] _ in
                self?.selectImage(from: .photoLibrary)
            }))
            actionVC.addAction(UIAlertAction(title: "카메라", style: .default, handler: { [weak self] _ in
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self?.selectImage(from: .photoLibrary)
                    return
                }
                self?.selectImage(from: .camera)
            }))
            actionVC.addAction(UIAlertAction(title: "일기 쓰기", style: .default, handler: { [weak self] _ in
                guard let nextVC = UIStoryboard(name: "Coredata", bundle: nil)
                    .instantiateViewController(withIdentifier: "entry_detail") as? EntryViewController else { return }
                nextVC.entry = CoreDataManager.shared.insert()
                self?.present(nextVC, animated: true)
            }))
            actionVC.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(actionVC, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
        picker.dismiss(animated: true, completion: nil)
        createEntryWithImage(pickingMediaWithInfo: info)
    }
}
