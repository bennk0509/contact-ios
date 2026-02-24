//
//  ContactService.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-26.
//
//
import UIKit
import Contacts

protocol ContactService: Sendable {
    func fetchAllContacts() async throws -> [CNContact]
    func fetchContactById(by id: String) async throws -> CNContact
}

actor ContactServiceImpl: ContactService {
    private let contactStore = CNContactStore()
    
    private var fetchAllTask: Task<[CNContact], Error>?
    private var fetchTask: [String: Task<CNContact,Error>] = [:]
    
    
    func fetchAllContacts() async throws -> [CNContact]{
        if let task = fetchAllTask{
            return try await task.value
        }
        
        let newTask = Task<[CNContact], Error>{
            var contacts: [CNContact] = []
            let keys = [
                CNContactIdentifierKey,
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactThumbnailImageDataKey,
                CNContactThumbnailImageDataKey,
            ] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            try self.contactStore.enumerateContacts(with: request){contact, _ in
                contacts.append(contact)
            }
            return contacts
        }
        
        
        self.fetchAllTask = newTask
        do {
            let result = try await newTask.value
            self.fetchAllTask = nil
            return result
        } catch {
            self.fetchAllTask = nil
            throw error
        }
        
    }

    func fetchContactById(by id: String) async throws -> CNContact
    {
        if let task = fetchTask[id]{
            return try await task.value
        }
        let newTask = Task{
            let keysToFetch = [
                CNContactIdentifierKey,
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactThumbnailImageDataKey,
                CNContactImageDataAvailableKey
            ] as [CNKeyDescriptor]
            let contact = try contactStore.unifiedContact(withIdentifier: id, keysToFetch: keysToFetch)
            return contact
        }
        
        self.fetchTask[id] = newTask
        do {
            let result = try await newTask.value
            self.fetchTask[id] = nil
            return result
        } catch{
            self.fetchTask[id] = nil
            throw error
        }        
        
    }

}
