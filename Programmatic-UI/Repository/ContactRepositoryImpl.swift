//
//  ContactRepositoryImpl.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//

import Contacts


class ContactRepositoryImpl: ContactRepository{
    private let service: ContactService
    
    init(service: ContactService = .shared) {
        self.service = service
    }
    
    func getAllIdentifiers() async throws -> [String] {
        return try await service.fetchAllContactIds()
    }
    
    func getContactsBatch(by ids: [String]) async throws -> [ContactModel] {
        let contacts = try await service.fetchContacts(by: ids)
        print("DEBUG: Service trả về \(contacts.count) raw contacts cho \(ids.count) IDs")
        let contactMap = Dictionary(uniqueKeysWithValues: contacts.map { ($0.identifier, $0) })
        
        return ids.compactMap { id in
            guard let raw = contactMap[id] else { return nil }
            return ContactModel(from: raw)
        }
    }
    
    func getThumbnail(for id: String) async throws -> Data? {
        return try await service.fetchThumbnails(for: id)
    }
    
}
