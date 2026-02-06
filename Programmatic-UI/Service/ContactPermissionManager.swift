//
//  ContactPermissionManager.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-31.
//

import Contacts

//option set

enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
    case limited
}


final class ContactPermissionManager {
    static let shared = ContactPermissionManager()
    private init() {}

    var currentStatus: PermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .limited: return .limited
        @unknown default: return .denied
        }
    }

    func request() async -> Bool {
        do {
            return try await CNContactStore().requestAccess(for: .contacts)
        } catch{
            return false
        }
    }
}
