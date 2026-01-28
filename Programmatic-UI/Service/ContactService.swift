//
//  ContactService.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-26.
//

import Contacts
import UIKit

class ContactService{
    //Create contactStore
    private let contactStore = CNContactStore()
    
    
    private var cachedGrouped: [String: [ContactModel]] = [:]
    private var cachedTitles: [String] = []
    
    
    
    deinit {
        print("De initialize Contact Service successfully")
    }
    
    func fetchAllContacts(completion: @escaping([ContactModel]?, Error?) -> Void){
        
        //Có nhiều người dùng weak self ở đây i dont even know why LOL
        contactStore.requestAccess(for: .contacts){ (result, error) in
            // IF user deny
            if let error = error {
                completion(nil, error)
                return
            }
            // IF user accept
            if result{
                DispatchQueue.global().async { [weak self] in
                    //Gọi hàm self lại. như kiểu Contact Service giữ call back này. rồi call back này giữu Contact Service. STRONG REFERENCE CYCLE
                    guard let self = self else {return}
                    self.performFetch(completion: completion)
                }
            }
            else{
                let accessError = NSError(domain: "ContactService", code: 1,
                                         userInfo: [NSLocalizedDescriptionKey: "Access Denied"])
                completion(nil, accessError)
                return
            }
        }
    }
    
    private func performFetch(completion: @escaping([ContactModel]?, Error?) -> Void){
        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataAvailableKey
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts: [ContactModel] = []
        
        do{
            try contactStore.enumerateContacts(with: request){ (contact, pointer) in
                let c = ContactModel(from: contact)
                contacts.append(c)
            }
            
            
            DispatchQueue.main.async {
                completion(contacts, nil)
            }
//            completion(contacts, nil)
            
            
        } catch{
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
}
