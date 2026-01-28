//
//  ContactModel.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//

import UIKit
import Contacts


struct ContactModel {
    let id: String
    let name: String
    let avatar: UIImage?
    let initial: String
    let color: UIColor
}

extension ContactModel{
    init(from contact: CNContact) {
        self.id = contact.identifier
        
        let fName = contact.givenName
        let lName = contact.familyName
        self.name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)


        let firstLetter = fName.first ?? " "
        let lastLetter = lName.first ?? " "
        let combinedInitial = "\(firstLetter)\(lastLetter)".trimmingCharacters(in: .whitespaces)
    
    
        self.initial = combinedInitial.isEmpty ? String(self.name.prefix(1)).uppercased() : combinedInitial.uppercased()
        
        self.color = ContactModel.generateColor(from: self.name)
        
        if contact.imageDataAvailable, let data = contact.thumbnailImageData {
            self.avatar = UIImage(data: data)
        } else {
            self.avatar = nil
        }
    }
}

extension ContactModel{
    static func generateColor(from input: String) -> UIColor {
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemPink]
        
        
        let hash = input.unicodeScalars.reduce(0) { $0 + $1.value }
        let index = Int(hash) % colors.count
        return colors[index]
    }
}
