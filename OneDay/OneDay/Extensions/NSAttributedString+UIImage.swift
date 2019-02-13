//
//  NSAttributedString+UIImage.swift
//  OneDay
//
//  Created by juhee on 13/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

extension NSAttributedString {
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
    var attributedString: NSAttributedString {
        let textAttachment = NSTextAttachment()
        textAttachment.image = self
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        return attrStringWithImage
    }
    
    func saveToFile() -> URL? {
        guard let data = self.jpegData(compressionQuality: 1) ?? self.pngData() else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        do {
            let timeStamp = Date().timeIntervalSince1970
            let url = directory.appendingPathComponent("entry_image_\(timeStamp).png")!
            try data.write(to: url)
            return url
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
