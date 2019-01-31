//
//  EntryDelegate.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

protocol EntryDelegate: class {
    func register(new entry: Entry)
    func update(entry: Entry)
}
