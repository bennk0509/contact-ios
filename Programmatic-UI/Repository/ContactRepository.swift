//
//  ContactRepository.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//

import Foundation
import Contacts

protocol ContactRepository{
    func fetchAllContacts() async throws -> [String]
    func fetchContact(id: String) async throws -> ContactModel
}


actor ContactRepositoryImpl{
    
    
    
    
    private let contactCache: NSCache<NSString,CacheEntryObject> = NSCache()
    private let contactService: ContactService
    
    private var fetchAllTask: Task<[ContactModel], Error>?

        
    private var contactsByID: [String: ContactModel] = [:]
    private var orderedIDs: [String] = []
    
    
    init(contactService: ContactService) {
        self.contactService = contactService
    }
    
    
    func fetchAllContacts() async throws -> [ContactModel]
    {
        if (!orderedIDs.isEmpty)
        {
            return orderedIDs.compactMap{contactsByID[$0]}
        }
        
        if let existingTask = fetchAllTask {
            return try await existingTask.value
        }
        
        let task = Task {
            let result = try await contactService.fetchAllContacts()
            return result.map{
                ContactModel(from: $0)
            }
            
        }
        
        self.fetchAllTask = task
        
        do {
            let contacts = try await task.value
            
            self.orderedIDs = contacts.map { $0.id }
            self.contactsByID = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
            
            self.fetchAllTask = nil
            
            return contacts
            
        } catch {
            self.fetchAllTask = nil
            throw error
        }
    }

    
    func fetchContact(id: String) async throws -> ContactModel {
        
        if let contact = contactsByID[id]
        {
            return contact
        }
        
        if let cached = await contactCache[id]{
            switch cached{
            case .inprogress(let task):
                return try await task.value
            case .ready(let contact):
                return contact
            }
        }
        
        let task = Task<ContactModel, Error>{
            let data = try await contactService.fetchContactById(by: id)
            let contact = await ContactModel(from: data)
            return contact
        }
        
        do{
            contactCache[id] = .inprogress(task)
            let contact = try await task.value
            contactCache[id] = .ready(contact)
            
            contactsByID[id] = contact
            orderedIDs.append(id)
            
            return contact
        } catch{
            
            contactCache[id] = nil
            throw error
        }
    }
}
