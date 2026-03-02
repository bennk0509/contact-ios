//
//  ContactViewModel.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//


import Foundation


@MainActor
final class ContactListViewModel{
    
    private let repository: ContactRepository
    init(repository: ContactRepository) {
        self.repository = repository
    }
    
    private(set) var permissionStatus: PermissionStatus = .notDetermined
    private(set) var contacts: [ContactModel] = []
    private var contactIDs: [String] = []
    private(set) var isLoadingMore: Bool = false
    func loadInitialData() async throws{
        let status = ContactPermissionManager.shared.currentStatus
        self.permissionStatus = status
        
        switch status {
        case .authorized:
            try await loadData()
        case .notDetermined:
            let granted = await ContactPermissionManager.shared.request()
            if granted {
                self.permissionStatus = .authorized
                try await loadData()
            } else {
                self.permissionStatus = .denied
            }
        case .denied, .restricted:
            return
        case .limited:
            try await loadData()
        }
    }
    func loadData() async throws {
        do{
            self.contacts = []
            self.contactIDs = []
            _ = try await repository.fetchAllContacts()
            self.contactIDs = try await repository.getOrderIds()
            self.contacts = try await repository.getContacts(for: Array(contactIDs.prefix(50)))
        } catch{
            throw error
        }
    }
    
    func loadNextPage() async throws -> Int{
        guard !isLoadingMore, contacts.count < contactIDs.count else {return 0}
        
        isLoadingMore = true
        
        defer { isLoadingMore = false }
        
        let start = contacts.count
        let end = min(start + 50, contactIDs.count)
        let nextIDs = Array(contactIDs[start..<end])
        
        do{
            let newContacts = try await repository.getContacts(for: nextIDs)
            self.contacts.append(contentsOf: newContacts)
            return newContacts.count
        } catch{
            throw error
        }
    }
    
    
}

