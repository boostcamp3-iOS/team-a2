//
//  ImageSource.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

enum ImageSource {
    case photoLibrary
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
