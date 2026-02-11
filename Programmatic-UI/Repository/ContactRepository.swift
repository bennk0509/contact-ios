//
//  ContactRepository.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//

import Foundation
import Contacts

protocol ContactRepository{
    func fetchAllContacts() async throws -> [ContactModel]
    func fetchContactById(id: String) async throws -> ContactModel
    func getOrderIds() async throws -> [String]
    func getContacts(for ids: [String]) async throws -> [ContactModel]
}

actor ContactRepositoryImpl: ContactRepository{
    private let contactService: ContactService
    
    init(contactService: ContactService) {
        self.contactService = contactService
    }
    
    private var contactsById: [String: ContactModel] = [:]
    private var orderedIds: [String] = []
    private var fetchAllTask: Task<[ContactModel], Error>?
    
    private var fetchTask: Task<ContactModel,Error>?
    
    
    func fetchAllContacts() async throws -> [ContactModel] {
        //Nếu N thằng fetch cùng lúc thì sẽ fetch N lần.
        if(!orderedIds.isEmpty)
        {
            return orderedIds.compactMap { contactsById[$0]}
        }
        
        if let task = fetchAllTask{
            return try await task.value
        }
        
        let task = Task{
            let data = try await contactService.fetchAllContacts()
            return data.map{
                ContactModel(from: $0)
            }
        }
        
        self.fetchAllTask  = task
        do {
            let contacts = try await task.value
            self.orderedIds = contacts.map { $0.id }
            self.contactsById = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
            
            self.fetchAllTask = nil
            return contacts
        } catch{
            throw error
        }
    }
    
    func fetchContactById(id: String) async throws -> ContactModel {
        if let contact = contactsById[id] {
            return contact
        }
        
        if let task = fetchTask{
            return try await task.value
        }
        
        let task = Task{
            let data = try await contactService.fetchContactById(by: id)
            return ContactModel(from: data)
        }
        self.fetchTask = task
        
        do{
            let contact = try await task.value
            self.contactsById[id] = contact
            if !orderedIds.contains(id){
                self.orderedIds.append(id)
            }
            return contact
        } catch{
            throw error
        }
    }
    
    func getOrderIds() async throws -> [String]
    {
        return orderedIds
    }
    
    func getContacts(for ids: [String]) async throws -> [ContactModel] {
        return ids.compactMap { contactsById[$0]}
    }
    
}
//    
//    func fetchContact(id: String) async throws -> ContactModel {
//        
//        if let contact = contactsByID[id]
//        {
//            return contact
//        }
//        
//        if let cached = await contactCache[id]{
//            switch cached{
//            case .inprogress(let task):
//                return try await task.value
//            case .ready(let contact):
//                return contact
//            }
//        }
//        
//        let task = Task<ContactModel, Error>{
//            let data = try await contactService.fetchContactById(by: id)
//            let contact = await ContactModel(from: data)
//            return contact
//        }
//        
//        do{
//            contactCache[id] = .inprogress(task)
//            let contact = try await task.value
//            contactCache[id] = .ready(contact)
//            
//            contactsByID[id] = contact
//            orderedIDs.append(id)
//            
//            return contact
//        } catch{
//            
//            contactCache[id] = nil
//            throw error
//        }
//    }
//}
