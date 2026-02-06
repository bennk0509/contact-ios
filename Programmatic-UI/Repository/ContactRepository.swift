//
//  ContactRepository.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//

import Foundation
import Contacts

//protocol ContactRepository{
//    func getAllContacts() async throws -> [String]
//    func getContactsBatch(by ids: [String]) async throws -> [ContactModel]
//}
//

actor ContactRepositoryImpl{
    
    
    private let contactCache: NSCache<NSString,CacheEntryObject> = NSCache()
    private let contactService: ContactService
    
    private var fetchAllTask: Task<[ContactModel], Error>?
    private var contacts: [ContactModel]?
    
    init(contactService: ContactService) {
        self.contactService = contactService
    }
    
    
    func fetchAllContacts() async throws -> [ContactModel]
    {
        if let exist = contacts{
            return exist
        }
        
        if let existingTask = fetchAllTask {
            return try await existingTask.value
        }
        
        let task = Task {
            let result = try await contactService.fetchAllContacts()
            return result.map{ContactModel(from: $0)}
            
        }
        
        self.fetchAllTask = task
        
        do {
            let contacts = try await task.value
            self.fetchAllTask = nil
            return contacts
        } catch {
            self.fetchAllTask = nil
            throw error
        }
    }

    
    func fetchContact(id: String) async throws -> ContactModel {
        
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
            
            return contact
        } catch{
            contactCache[id] = nil
            throw error
        }
    }
}
