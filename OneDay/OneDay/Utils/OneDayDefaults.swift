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
    private static let keyRecentKeyword = "current_keywords"
    
    static let DidChangedRecentKeywordsNotification: Notification.Name = Notification.Name("didChangedRecentKeywordsNotification")
    
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
    
    private static var _currentKeywords: [String] = defaults.stringArray(forKey: keyRecentKeyword) ?? [] {
        willSet(newValue) {
            defaults.set(newValue, forKey: keyRecentKeyword)
        }
        didSet {
            NotificationCenter.default.post(name: OneDayDefaults.DidChangedRecentKeywordsNotification, object: nil)
        }
    }
    
    static func addCurrentKeywords(keyword: String) {
        let oldKeyowrds = _currentKeywords
        if !oldKeyowrds.contains(keyword) {
            _currentKeywords.append(keyword)
        }
    }
    
    static var currentKeywords: [String] {
        return _currentKeywords
    }
}
