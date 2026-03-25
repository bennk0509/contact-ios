//
//  ContactViewModel.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//

import Foundation

enum LoadingState {
    case rest
    case loading
    case error
}

@MainActor
final class ContactListViewModel {
    ///
    private let repository: ContactRepository

    private(set) var permissionStatus: PermissionStatus = .notDetermined
    private(set) var contacts: [ContactModel] = []
    private(set) var filteredContacts: [ContactModel] = []
    private(set) var isLoading: LoadingState = .rest

    private var contactIDs: [String] = []
    
    private var searchTask: Task<Void,Never>?

    /// Constructor HERE
    init(repository: ContactRepository) {
        self.repository = repository
    }

    /// FUNC HERE
    func loadInitialData() async throws {
        let status = ContactPermissionManager.shared.currentStatus
        permissionStatus = status

        switch status {
        case .authorized:
            try await loadData()
        case .notDetermined:
            let granted = await ContactPermissionManager.shared.request()
            if granted {
                permissionStatus = .authorized
                try await loadData()
            } else {
                permissionStatus = .denied
            }
        case .denied, .restricted:
            return
        case .limited:
            try await loadData()
        }
    }

    private func loadData() async throws {
        isLoading = .loading
        do {
            contacts = []
            contactIDs = []

            _ = try await repository.fetchAllContacts()

            contactIDs = try await repository.getOrderIds()

            let firstPageIDs = Array(contactIDs.prefix(50))
            contacts = try await repository.getContacts(for: firstPageIDs)
            isLoading = .rest
        } catch {
            isLoading = .error
            throw error
        }
    }
    func loadNextPage() async throws {
        guard contacts.count < contactIDs.count, isLoading == .rest else {
            return
        }
        isLoading = .loading
        let start = contacts.count
        let end = min(start + 50, contactIDs.count)
        let nextIDs = Array(contactIDs[start ..< end])
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            let result = try await repository.getContacts(for: nextIDs)
            contacts.append(contentsOf: result)
            isLoading = .rest
        } catch {
            isLoading = .error
            throw error
        }
    }

//    func loadNextPage() async throws -> [ContactModel] {
//        guard contacts.count < contactIDs.count else {
//            return []
//        }
//        let start = contacts.count
//        let end = min(start + 50, contactIDs.count)
//        let nextIDs = Array(contactIDs[start ..< end])
//
//        do {
//            try await Task.sleep(nanoseconds: 5_000_000_000)
//            let result = try await repository.getContacts(for: nextIDs)
//            isLoading = .rest
//            return result
//        } catch {
//            isLoading = .error
//            throw error
//        }
//    }

    func appendContacts(_ newContacts: [ContactModel]) {
        contacts.append(contentsOf: newContacts)
        isLoading = .rest
    }

    func search(query: String) async {
        searchTask?.cancel()
        searchTask = Task {
            guard !query.isEmpty else {
                filteredContacts = contacts
                return
            }
            let result = await repository.searchContacts(query: query)
            if(Task.isCancelled) {return}
            filteredContacts = result
        }
        await searchTask?.value
    }
}
