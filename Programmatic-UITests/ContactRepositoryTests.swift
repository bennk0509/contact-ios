//
//  ContactRepositoryTests.swift.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-06.
//

import XCTest
import Contacts
@testable import Programmatic_UI

actor MockContactService: ContactService {
    var fetchAllCallCount = 0
    var fetchByIdCallCount: [String: Int] = [:]
    var mockData: [CNContact] = []

    func fetchAllContacts() async throws -> [CNContact] {
        fetchAllCallCount += 1
//        try await Task.sleep(nanoseconds: 100_000_000)
        return mockData
    }

    func fetchContactById(by id: String) async throws -> CNContact {
        fetchByIdCallCount[id, default: 0] += 1
        try await Task.sleep(nanoseconds: 100_000_000)
        return CNContact()
    }
    func fetchAllContactIDs() async throws -> [String] {
        return []
    }
}

final class ContactRepositoryTests: XCTestCase {
    var sut: ContactRepositoryImpl!
    var mockService: MockContactService!

    override func setUp() {
        super.setUp()
        mockService = MockContactService()
        sut = ContactRepositoryImpl(contactService: mockService)
    }
    
    func testFetchAllContacts_ShouldOnlyCallServiceOnce_WhenMultipleCallsOccur() async throws {
        let totalRequests = 5000
        
        try await withThrowingTaskGroup(of: [ContactModel].self) { group in
            for _ in 0..<totalRequests {
                group.addTask {
                    return try await self.sut.fetchAllContacts()
                }
            }
            for try await _ in group { }
        }
        
        let callCount = await mockService.fetchAllCallCount
        XCTAssertEqual(callCount, 1, "fetchAllTasks call only 1 times to the Service")
    }
    
    func testFetchContactById_ShouldReturnFromCache_WhenAlreadyFetched() async throws {
        let testId = "123"
        _ = try await sut.fetchContactById(id: testId)
        _ = try await sut.fetchContactById(id: testId)
        let callCount = await mockService.fetchByIdCallCount[testId]
        XCTAssertEqual(callCount, 1)
    }

    func testFetchContactById_ShouldHandleConcurrentCallsForSameId() async throws {
        let testId = "ABC"
        await withTaskGroup(of: ContactModel.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    return try! await self.sut.fetchContactById(id: testId)
                }
            }
            for await _ in group {}
        }
        let callCount = await mockService.fetchByIdCallCount[testId]
        XCTAssertEqual(callCount, 1)
    }

    func testFetchAll_ShouldResetTask_WhenErrorOccurs() async throws {
        struct DummyError: Error {}
    }

    func testOrderedIds_ShouldMaintainSequence() async throws {
        // GIVEN: Giả lập 3 contacts trả về từ service
        // WHEN: fetchAllContacts()
        // THEN: orderedIds phải chứa đúng 3 ID theo thứ tự đó
    }
}

