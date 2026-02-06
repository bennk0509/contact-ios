//
//  NSCache+Subscript.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-05.
//
import Foundation


extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject{
    
    subscript(id: String) -> CacheEntry?{
        get{
            let key = id as NSString
            let value = object(forKey: key)
            return value?.entry
        }
        set{
            let key = id as NSString
            if let entry = newValue{
                let value = CacheEntryObject(entry: entry)
                setObject(value, forKey: key)
            } else{
                removeObject(forKey: key)
            }
        }
    }
}
