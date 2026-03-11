//
//  ContactViewModel.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//


import Foundation

enum LoadingState{
    case rest
    case loading
    case error
}



@MainActor
final class ContactListViewModel{
    //
    private let repository: ContactRepository
    
    private(set) var permissionStatus: PermissionStatus = .notDetermined
    private(set) var contacts: [ContactModel] = []
    private(set) var isLoading: LoadingState = .rest
    
    private var contactIDs: [String] = []
    
    //Constructor HERE
    init(repository: ContactRepository) {
        self.repository = repository
    }
    
    //FUNC HERE
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
        isLoading = .loading
        defer { isLoading = .rest }
        
        do {
            self.contacts = []
            self.contactIDs = []
            
            _ = try await repository.fetchAllContacts()
            self.contactIDs = try await repository.getOrderIds()
            
            let firstPageIDs = Array(contactIDs.prefix(50))
            self.contacts = try await repository.getContacts(for: firstPageIDs)
        } catch {
            isLoading = .error
            throw error
        }
    }
    
    func loadNextPage() async throws -> [ContactModel] {
        guard contacts.count < contactIDs.count else {
            return []
        }
    
        defer {
            if isLoading == .loading { isLoading = .rest }
        }
        
        let start = contacts.count
        let end = min(start + 50, contactIDs.count)
        let nextIDs = Array(contactIDs[start..<end])
        
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            return try await repository.getContacts(for: nextIDs)
        } catch {
            isLoading = .error
            throw error
        }
    }
    
    func setLoadingState(loadingState: LoadingState)
    {
        self.isLoading = loadingState
    }
    
    func resetLoadingState(){
        self.isLoading = .rest
    }
    
    func appendContacts(_ newContacts: [ContactModel]){
        self.contacts.append(contentsOf: newContacts)
        self.isLoading = .rest
    }
    
}

