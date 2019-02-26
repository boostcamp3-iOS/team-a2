//
//  String+URL.swift
//  OneDay
//
//  Created by juhee on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

extension String {
    /**
     String으로 파일 시스템의 Document Directory URL을 반환
     
     파일 경로나 폴더가 없다면 만든다.
     */
    var urlForDataStorage: URL? {
        let fileManager = FileManager.default
        guard let folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let appFolder = folder.appendingPathComponent("OneDay")
        var isDirectory: ObjCBool = false
        let folderExists = fileManager.fileExists(atPath: appFolder.path, isDirectory: &isDirectory)
        if !folderExists || !isDirectory.boolValue {
            do {
                try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        return appFolder.appendingPathComponent(self).appendingPathExtension("jpeg")
    }
}
