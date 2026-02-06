//
//  CacheEntryObject.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-05.
//

enum CacheEntry{
    case inprogress(Task<ContactModel,Error>)
    case ready(ContactModel)
}


final class CacheEntryObject{
    let entry: CacheEntry
    
    init(entry: CacheEntry) {
        self.entry = entry
    }
}
