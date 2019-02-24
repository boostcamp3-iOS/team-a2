//
//  JournalService.swift
//  OneDayTests
//
//  Created by juhee on 28/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import XCTest
@testable import OneDay

class JournalServiceTest: XCTestCase {
    /*
    // MARK: Properties
    var journalService: CoreDataJournalService!
    var coreDataStack: TestCoreDataStack!

    override func setUp() {
        coreDataStack = TestCoreDataStack()
//        journalService = JournalService(managedObjectContext: coreDataStack.managedContext, coreDataStack: coreDataStack)
    }

    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
        journalService = nil
    }
    
    func testRootContextIsSavedAfterAddingCamper() {
        let derivedContext = coreDataStack.newDerivedContext()
//        journalService = JournalService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
        
        expectation(
            forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.managedContext) { _ in
                return true
        }
        
        derivedContext.perform {
            let journal = self.journalService.journal("모든 항목", index: 0)
            XCTAssertNotNil(journal)
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testAddJournal() {
        let journal = journalService.journal("일지", index: 1)
        
        XCTAssertNotNil(journal, "Camper should not be nil")
        XCTAssertTrue(journal.title == "일지")
        XCTAssertTrue(journal.index == 1)
    }
    
    func testGetJournals() {
        _ = journalService.journal("모든 항목", index: 0)
        _ = journalService.journal("일지", index: 1)
        let journals = journalService.journals()
        
        XCTAssertNotNil(journals, "Camper should not be nil")
        print("journals : \(journals.count)")
        XCTAssertTrue(journals[0].title == "모든 항목")
        XCTAssertTrue(journals.count == 2)
    }
    */
}
