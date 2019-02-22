//
//  ImageSource.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

/**
 UIImagePickerController에서 source type
 
 - photoLibrary: 기존 사용자의 앨범에서 사진을 불러오기
 - camera: 카메라에서 새로운 사진 촬영
 */
enum ImageSource {
    /** 기존 사용자의 앨범에서 사진을 불러오기 */
    case photoLibrary
    /** 카메라에서 새로운 사진 촬영 */
    case camera
    
    var sourceType: UIImagePickerController.SourceType {
        switch self {
        case .photoLibrary:
            return .photoLibrary
        case .camera:
            return .camera
        }
    }
}
