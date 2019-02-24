//
//  AddActionViewController.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

/// 세 번째 탭인 + 탭을 눌렀을 때 호출되는 ViewController
class AddActionViewController: UIViewController { }

extension AddActionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     이미지 피커에서 이미지 선택이 완료되었을 때 호출된다.
     picker를 내려주고 선택된 이미지를 받아서 Entry Contents에 담아서 EntryViewController로 이동하는 createEntryWithImage()를 호출한다.
     */
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
        picker.dismiss(animated: true, completion: nil)
        createEntryWithImage(pickingMediaWithInfo: info)
    }
}
