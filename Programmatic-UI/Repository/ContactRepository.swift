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
    func searchContacts(query: String) async -> [ContactModel]
}

actor ContactRepositoryImpl: ContactRepository{
    private let contactService: ContactService
    
    init(contactService: ContactService) {
        self.contactService = contactService
    }
    
    private var contactsById: [String: ContactModel] = [:]
    private var orderedIds: [String] = []

    func searchContacts(query: String) async -> [ContactModel] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        let lowerQuery = query.lowercased()
        //reader writer lock
        return contactsById.values.filter { contact in
            contact.name.lowercased().contains(lowerQuery)
        }
    }
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
