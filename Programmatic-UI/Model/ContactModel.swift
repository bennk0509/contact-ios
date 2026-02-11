//
//  ContactModel.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//



import Foundation
import Contacts

struct ContactModel: Hashable, Sendable {
    let id: String
    let name: String
    let initial: String
    let colorIndex: Int
    let avatarData: Data?
}

extension ContactModel {
    nonisolated init(from contact: CNContact) {
        let fName = contact.givenName
        let lName = contact.familyName
        
        self.id = contact.identifier
        self.name = "\(fName) \(lName)".trimmingCharacters(in: .whitespaces)

        let firstLetter = fName.first ?? " "
        let lastLetter = lName.first ?? " "
        let combinedInitial = "\(firstLetter)\(lastLetter)".trimmingCharacters(in: .whitespaces)

        self.initial = combinedInitial.isEmpty ? String(self.name.prefix(1)).uppercased() : combinedInitial.uppercased()
        
        self.avatarData = contact.thumbnailImageData
        self.colorIndex = abs(contact.identifier.hashValue)
    }
}
