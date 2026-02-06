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
    
    
    func fetchAllContacts() async throws -> [CNContact]{
        var contacts: [CNContact] = []
        let keys = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataAvailableKey,
        ] as [CNKeyDescriptor]
        
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        try self.contactStore.enumerateContacts(with: request){contact, _ in
            contacts.append(contact)
        }
        return contacts
    }
    
    func fetchAllContactIDs() async throws -> [String]
    {
        var ids: [String] = []
        let keys = [CNContactIdentifierKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        try self.contactStore.enumerateContacts(with: request){ contact,_ in
            ids.append(contact.identifier)
        }
        return ids
    }
    
    func fetchContactById(by id: String) async throws -> CNContact
    {
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

}
