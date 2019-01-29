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
    var contentService: ContentService!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        coreDataStack = TestCoreDataStack()
        entryService = EntryService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
        journalService = JournalService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
        contentService = ContentService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
        journalService = nil
        entryService = nil
        contentService = nil
    }
    
    func testRootContextIsSavedAfterAddingCamper() {
        let derivedContext = coreDataStack.newDerivedContext()
        entryService = EntryService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
        
        expectation(
        forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { notification in
            return true
        }
        
        derivedContext.perform {
            let journal = self.journalService.journal("모든 항목", index: 0)
            XCTAssertNotNil(journal)
            let contents: [Content] = []
            contents.append(TextContent())
            let entry = self.entryService.entry("안녕", contents: [])
            let content = self.contentService.contents(entry: <#T##Entry#>, contents: <#T##[Content]#>)
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testAddEntry() {
        let journal = entryService.addJournal("일지", index: 1)
        
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
}
