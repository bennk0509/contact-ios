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

    
    func fetchAllContacts() async throws -> [ContactModel] {
        if(!orderedIds.isEmpty)
        {
            return orderedIds.compactMap { contactsById[$0]}
        }

        let data = try await contactService.fetchAllContacts()
        let models = data.map { ContactModel(from: $0) }
        self.contactsById = Dictionary(uniqueKeysWithValues: models.map { ($0.id, $0) })
        self.orderedIds = models.map { $0.id }
        
        return models
    }
    
    func fetchContactById(id: String) async throws -> ContactModel {
        if let contact = contactsById[id] {
            return contact
        }

        let data = try await contactService.fetchContactById(by: id)
        let contact = ContactModel(from: data)
        
        self.contactsById[id] = contact
        if !orderedIds.contains(id){
            self.orderedIds.append(id)
        }
        return contact
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
