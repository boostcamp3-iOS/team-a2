//
//  EntryServiceTest.swift
//  OneDayTests
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import XCTest
@testable import OneDay

class EntryServiceTest: XCTestCase {
    // MARK: Properties
    var entryService: EntryService!
    var journalService: JournalService!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        coreDataStack = TestCoreDataStack()
        entryService = EntryService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
        journalService = JournalService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
        journalService = nil
        entryService = nil
    }
    
    func testRootContextIsSavedAfterAddingCamper() {
        let derivedContext = coreDataStack.newDerivedContext()
        entryService = EntryService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
        
        expectation(
        forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { _ in
            return true
        }
        
        derivedContext.perform {
            let entry = self.entryService.entry("안녕", contents: NSAttributedString(string: "Hi"))
            XCTAssertNotNil(entry)
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testAddEntry() {
        let contents = NSAttributedString(string: "안녕")
        let entry = entryService.entry("일지", contents: contents)
        
        XCTAssertNotNil(entry, "Camper should not be nil")
        XCTAssertTrue(entry.title == "일지")
    }
    
    func testGetEntrie() {
        _ = journalService.journal("모든 항목", index: 0)
        _ = journalService.journal("일지", index: 1)
        let journals = journalService.journals()
        
        XCTAssertNotNil(journals, "Camper should not be nil")
        print("journals : \(journals.count)")
        XCTAssertTrue(journals[0].title == "모든 항목")
        XCTAssertTrue(journals.count == 2)
    }
}
