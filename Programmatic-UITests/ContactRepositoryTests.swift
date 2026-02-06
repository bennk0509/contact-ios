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
    
    var count = 0
    
    var countFetchID = 0
    
    func fetchAllContacts() async throws -> [CNContact] {
        count += 1
        try await Task.sleep(nanoseconds: 500_000_000)
        return []
    }
    
    func fetchAllContactIDs() async throws -> [String] {
        return []
    }
    
    func fetchContactById(by id: String) async throws -> CNContact {
        countFetchID += 1
        try await Task.sleep(nanoseconds: 500_000_000)
        return CNContact()
    }
    
}


final class ContactRepositoryTests: XCTestCase{
    func testFetchAllContactsWith5000Calls() async throws {
        let mock = MockContactService()
        let repo = ContactRepositoryImpl(contactService: mock)
        let totalRequests = 5000
        
        try await withThrowingTaskGroup(of: [ContactModel].self) { group in
            for _ in 1...totalRequests {
                group.addTask {
                    return try await repo.fetchAllContacts()
                }
            }
            for try await _ in group { }
        }
        
        let count = await mock.count
        XCTAssertEqual(count, 1, "Need to call exactly 1 time only!!")
        print(count)
    }
    
    func testFetchContactByIdWith5000Call() async throws {
        let mock = MockContactService()
        let repo = ContactRepositoryImpl(contactService: mock)
        let totalRequest = 5000
        try await withThrowingTaskGroup(of: ContactModel.self){ group in
            for _ in 1...totalRequest{
                group.addTask{
                    return try await repo.fetchContact(id: "177C371E-701D-42F8-A03B-C61CA31627F6")
                }
            }
            for try await _ in group {}
        }
         
        let count = await mock.countFetchID
        print(count)
    }
    
    func testGetAllContacts() async throws {
        let service = await ContactServiceImpl()
        let sut = ContactRepositoryImpl(contactService: service)
        try await withThrowingTaskGroup(of: [ContactModel].self) { group in
            for _ in 1...5000 {
                group.addTask {
                    return try await sut.fetchAllContacts()
                }
            }
            var completedRequests = 0
            for try await contacts in group {
                completedRequests += 1
                XCTAssertFalse(contacts.isEmpty, "Dữ liệu trả về không được rỗng")
                
                if completedRequests <= 2 {
                    print("--------- Request #\(completedRequests) ---------")
                    let sample = contacts.prefix(2)
                    for contact in sample {
                        print("ID: \(contact.id) - Name: \(contact.name)")
                    }
                }
            }
        }
        
        
        
        print("Integration Test: 5000 requests đồng thời trên dữ liệu thật thành công!")
    }
}
