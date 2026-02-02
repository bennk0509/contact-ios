//
//  ContactViewModel.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//


import Foundation
class ContactViewModel{
    private let repository: ContactRepository
    init(repository: ContactRepository) {
        self.repository = repository
    }
    
    private(set) var contacts: [ContactModel] = []
    
    
    var isLoading = false {
        didSet{
            onLoading?(isLoading)
        }
    }
    var hasMoreData = true
    var allContactIDs: [String] = []
    
    var currentPage = 0
    let pageSize = 50
    
    var onError: ((String) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    func handlePermission() async {
        let status = ContactPermissionManager.shared.currentStatus
        switch status{
        case .authorized, .limited:
            await fetchIds()
        case .denied:
            onError?("denied")
        case .restricted:
            onError?("restricted")
        case .notDetermined:
            let granted = await ContactPermissionManager.shared.request()
            if granted{
                await fetchIds()
            } else{
                onError?("denied")
            }
        }
    }
    
    func fetchIds() async{
        guard !isLoading else { return }
        isLoading = true
        do {
            allContactIDs = try await repository.getAllIdentifiers()
            isLoading = false
            await loadNextPage()
        } catch {
            onError?("Cant access to contacts: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func loadNextPage() async{
        guard !isLoading, hasMoreData else { return }
        isLoading = true
        
        
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allContactIDs.count)
        
        guard startIndex < endIndex else{
            hasMoreData = false
            isLoading = false
            return
        }
        
        let batchIDs = Array(allContactIDs[startIndex..<endIndex])
        do {
            let newContacts = try await repository.getContactsBatch(by: batchIDs)
            self.contacts.append(contentsOf: newContacts)
            
            self.currentPage += 1
            
            
            self.isLoading = false
            self.onDataUpdated?()
            
            if endIndex == allContactIDs.count {
                hasMoreData = false
            }
        } catch {
            print("ERROR")
            onError?("Error \(currentPage): \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func fetchThumbnail(for contactID: String) async -> Data? {
        return try? await repository.getThumbnail(for: contactID)
    }
}
