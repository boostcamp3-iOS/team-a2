//
//  UIViewController+UIImagePickerControllerDelegate.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

extension UIImagePickerControllerDelegate where Self: UIViewController, Self: UINavigationControllerDelegate {
    /**
     UIImagePickerController에서 image가 넘어오면 EntryViewController 로 이동시키는 함수
     
     - Parameters:
     - source: Instance of ImageSource Enum. camera or album
     
     - Returns: editedImage 혹은 originImage를 찾을 수 없을 경우 return
     */
    func selectImage(from source: ImageSource) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source.sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     UIImagePickerController에서 image가 넘어오면 EntryViewController 로 이동시키는 함수
     
     - Parameters:
        - pickingMediaWithInfo: UIImagePickerController에서 넘겨주는 MediaInfo
     
     - Returns: editedImage 혹은 originImage를 찾을 수 없을 경우 return
     */
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
        
        guard let nextVC = UIStoryboard(name: "Coredata", bundle: nil)
            .instantiateViewController(withIdentifier: "entry_detail") as? EntryViewController else { return }
        let newEntry: Entry = CoreDataManager.shared.insert(type: Entry.self)
        newEntry.contents = scaledImage.attributedString
        nextVC.entry = newEntry
        present(nextVC, animated: true)
    }
}
