//
//  ContactService.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-26.
//
//
import UIKit
import Contacts

actor ContactService {
    static let shared = ContactService()
    private init(){}
    private let contactStore = CNContactStore()
    
    
    func fetchAllContactIds() async throws -> [String]{
        var ids: [String]  = []
        let keys = [CNContactIdentifierKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        try self.contactStore.enumerateContacts(with: request){ contact, _ in
            ids.append(contact.identifier)
        }
        return ids
        
    }
    
    func fetchContacts(by ids: [String]) async throws -> [CNContact]
    {
        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataAvailableKey
        ] as [CNKeyDescriptor]
        
        let predicate = CNContact.predicateForContacts(withIdentifiers: ids)
        
        return try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
    }
    
    
    func fetchThumbnails(for identifier: String) throws -> Data? {
        let keys = [CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
        let contact = try contactStore.unifiedContact(withIdentifier: identifier, keysToFetch: keys)
        return contact.thumbnailImageData
    }
    
}
