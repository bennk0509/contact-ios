//
//  ContactRepository.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-02.
//

import Foundation

protocol ContactRepository{
    func getAllIdentifiers() async throws -> [String]
    func getContactsBatch(by ids: [String]) async throws -> [ContactModel]
    func getThumbnail(for id: String) async throws -> Data?
}
