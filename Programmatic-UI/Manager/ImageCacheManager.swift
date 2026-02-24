//
//  ImageCacheManager.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-02-24.
//

import UIKit


final class CacheNode: @unchecked Sendable{
    let key: String
    var value: UIImage
    var next: CacheNode?
    weak var prev: CacheNode?
    
    init(key: String, value: UIImage, next: CacheNode? = nil, prev: CacheNode? = nil) {
        self.key = key
        self.value = value
        self.next = next
        self.prev = prev
    }
}

actor LRUImageCache{
    private let capacity: Int
    
    private var dict: [String: CacheNode] = [:]
    
    private var head: CacheNode?
    private var tail: CacheNode?
    
    
    func get(key: String) -> UIImage? {
        guard let node = dict[key] else { return nil }
        move2Head(node)
        return node.value
    }
    
    func set(key: String, value: UIImage){
        if let node = dict[key] {
            node.value = value
            move2Head(node)
        } else{
            let newNode = CacheNode(key: key, value: value)
            dict[key] = newNode
            //Add Node here
            addNode(newNode)
            
            if(dict.count > capacity){
                if let last = tail {
                    dict.removeValue(forKey: last.key)
                    removeNode(newNode)
                    //Remove Node here
                    
                }
            }
        }
    }
    
    private func addNode(_ node: CacheNode){
        node.next = head
        head?.prev = node
        head = node
        if (tail == nil){tail = head}
    }
    private func removeNode(_ node: CacheNode){
        if(node === head) {head = node.next}
        if(node === tail) {tail = node.prev}
        
        node.prev?.next = node.next
        node.next?.prev = node.prev
        
        node.next = nil
        node.prev = nil
        
    }
    
    private func move2Head(_ node: CacheNode){
        removeNode(node)
        addNode(node)
    }
    
    init(capacity: Int) {
        self.capacity = capacity
    }
}

actor ImageCacheManager{
    static let shared = ImageCacheManager()
    
    
    private let lru = LRUImageCache(capacity: 100)
    
    func getCachedImage(for id: String) async -> UIImage? {
        return await lru.get(key: id)
    }
    
    func cacheImage(_ image: UIImage, for id: String) async {
        await lru.set(key: id, value: image)
    }
    
}
