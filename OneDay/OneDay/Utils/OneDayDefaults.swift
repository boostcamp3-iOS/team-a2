//
//  OneDayDefaults.swift
//  OneDay
//
//  Created by juhee on 12/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import Foundation

/**
 UserDefatuls로 저장할 내역
 
 - current_journal : 최근 선택된 journal 의 journalId 를 uuidString 저장
 - current_keywords : 사용자가 검색한 검색어를 저장하는 string array
 */
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
