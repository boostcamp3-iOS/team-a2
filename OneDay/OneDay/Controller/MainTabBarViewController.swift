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
                self?.selectImageFrom(.photoLibrary)
            }))
            actionVC.addAction(UIAlertAction(title: "카메라", style: .default, handler: { [weak self] _ in
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self?.selectImageFrom(.photoLibrary)
                    return
                }
                self?.selectImageFrom(.camera)
            }))
            actionVC.addAction(UIAlertAction(title: "일기 쓰기", style: .default, handler: { [weak self] _ in
                guard let nextVC = UIStoryboard(name: "Coredata", bundle: nil).instantiateViewController(withIdentifier: "entry_detail") as? EntryViewController else { return }
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

class AddActionViewController: UIViewController {
    
}
extension AddActionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
        picker.dismiss(animated: true, completion: nil)
        createEntryWithImage(pickingMediaWithInfo: info)
    }
}

enum ImageSource {
    case photoLibrary
    case camera
}

extension UIImagePickerControllerDelegate where Self: UIViewController, Self: UINavigationControllerDelegate {
    
    func selectImageFrom(_ source: ImageSource) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func createEntryWithImage(pickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var pickedImage: UIImage!
        if let editedImage = info[.editedImage] as? UIImage {
            pickedImage = editedImage
        } else if let originImage = info[.originalImage] as? UIImage {
            pickedImage = originImage
        } else {
            print("Image not found!")
            return
        }
        
        let originWidth = pickedImage.size.width
        let scaleFactor = originWidth / (view.frame.size.width - 10)
        let scaledImage =  UIImage(cgImage: pickedImage.cgImage!, scale: scaleFactor, orientation: .up)
        
        guard let nextVC = UIStoryboard(name: "Coredata", bundle: nil).instantiateViewController(withIdentifier: "entry_detail") as? EntryViewController else { return }
        let newEntry: Entry = CoreDataManager.shared.insert()
        newEntry.contents = scaledImage.attributedString
        nextVC.entry = newEntry
        present(nextVC, animated: true)
    }
    
}
