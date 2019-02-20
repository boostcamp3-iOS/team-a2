//
//  OneDayDefaults.swift
//  OneDay
//
//  Created by juhee on 12/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

class OneDayDefaults {

    private static let defaults = UserDefaults.standard
    private static let keyDefaultJournal = "initalJournal"
    private static let keyCurrentJournal = "current_journal_uuidString"
    private static let keyCurrentKeyword = "current_keywords"
    
    static var defaultJournalUUID: String? = defaults.string(forKey: keyDefaultJournal) {
        willSet(newValue) {
            defaults.set(newValue, forKey: keyDefaultJournal)
        }
    }
    
    static var currentJournalUUID: String? = defaults.string(forKey: keyCurrentJournal) {
        willSet(newValue) {
            defaults.set(newValue, forKey: keyCurrentJournal)
        }
    }
    
    static var currentKeywords: [String] = defaults.stringArray(forKey: keyCurrentKeyword) ?? [] {
        willSet(newValue) {
            defaults.set(newValue, forKey: keyCurrentKeyword)
        }
    }
    
    static func addNewKeyword(keyword: String) {
        currentKeywords.append(keyword)
    }
}
