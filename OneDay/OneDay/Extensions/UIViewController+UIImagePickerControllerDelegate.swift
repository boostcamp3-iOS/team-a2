//
//  UIViewController+UIImagePickerControllerDelegate.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

extension UIImagePickerControllerDelegate where Self: UIViewController, Self: UINavigationControllerDelegate {
    
    func selectImage(from source: ImageSource) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source.sourceType
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
        
        guard let nextVC = UIStoryboard(name: "Coredata", bundle: nil)
            .instantiateViewController(withIdentifier: "entry_detail") as? EntryViewController else { return }
        let newEntry: Entry = CoreDataManager.shared.insert()
        newEntry.contents = scaledImage.attributedString
        nextVC.entry = newEntry
        present(nextVC, animated: true)
    }
}
