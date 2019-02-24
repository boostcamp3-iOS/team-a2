//
//  NSAttributedString+UIImage.swift
//  OneDay
//
//  Created by juhee on 13/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

extension NSAttributedString {
    /**
     NSAttributedString에서 포함하고 있는 image를 반환한다.
     
     - NSAttributedString을 돌면서 attachment를 포함하고 있다면 attachment가 image인지 판단하고 추출하여 return 객체에 담는다.
     - image를 찾아내는 시점에서 NSAttributedString 탐색을 중단한다.
     
     - Returns: NSAttributedString에서 찾아낸 Image 혹은 nil
     */
    var firstImage: UIImage? {
        let range = NSRange(location: 0, length: self.length)
        var result: UIImage?
        self.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (object, range, stop) in
            if object.keys.contains(NSAttributedString.Key.attachment) {
                if let attachment = object[NSAttributedString.Key.attachment] as? NSTextAttachment {
                    if let image = attachment.image {
                        result = image
                        stop.pointee = true
                    } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                        result = image
                        stop.pointee = true
                    }
                }
            }
        }
        return result
    }
}

extension UIImage {
    /**
     UIImage를 NSAttributedString으로 변환한 갑
     
     - UIImage를 Attachment로 포함한 NSAttributedString
     */
    var attributedString: NSAttributedString {
        let textAttachment = NSTextAttachment()
        textAttachment.image = self
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        let mutable = NSMutableAttributedString(attributedString: attrStringWithImage)
        mutable.append(NSAttributedString(string: "\n\n"))
        return mutable
    }
    
    /**
     UIImage를 File로 저장하고 성공여부를 반환한다.
     
     - Parameters:
        - fileName: 이미지를 저장할 파일 이름
     
     - Returns: 성공적으로 파일에 저장되었는지 여부
     */
    func saveToFile(fileName: String) -> Bool {
        guard let data = self.jpegData(compressionQuality: 0.8) else {
            return false
        }

        guard let urlForDataStorage = fileName.urlForDataStorage else { return false }
        
        do {
            try data.write(to: urlForDataStorage)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
