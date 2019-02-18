//
//  AddActionViewController.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

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
