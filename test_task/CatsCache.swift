//
//  CatsCache.swift
//  test_task
//
//  Created by Вадим on 29.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation
import UIKit

class CatsCache {
    
    private(set) var cats: [Cat]
    private lazy var catsCache = NSCache<NSString, UIImage>()
    
    private var networkManager: CatsNetworkManager
    private var downloadTracker: [Bool]
    
    
    init(cats: [Cat], networkManager: CatsNetworkManager) {
        self.cats = cats
        self.networkManager = networkManager
        downloadTracker = Array(repeating: false, count: cats.count)
    }
    
    private let lock = NSLock()
    
    public func addCats(_ newCats: [Cat]) {
        var fixedCats = newCats
        cats.forEach { cat in
            fixedCats.removeAll{ _newCat in _newCat == cat }
        }
        self.cats += fixedCats
        self.downloadTracker += Array(repeating: false, count: fixedCats.count)
    }
}

extension CatsCache {
    public func insertCatImage(_ image: UIImage, for url: String) {
        lock.lock(); defer { lock.unlock() }
        catsCache.setObject(image, forKey: url as NSString)
      }

    public func removeCatImage(at index: Int) {
    lock.lock(); defer { lock.unlock() }
        if cats.indices.contains(index) {
            catsCache.removeObject(forKey: cats[index].url! as NSString)
        }
    }
}

extension CatsCache {
    public func catImage(at index: Int) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        guard let url = cats[index].url as NSString? else { return nil }
        if let image = catsCache.object(forKey: url) {
            return image
        } else {
            guard let index = cats.firstIndex(of: cats[index]) else { return nil }
            if downloadTracker[index] { return nil }
            downloadTracker[index] = true
            
            networkManager.getImage(from: url as String) { [unowned self] result in
                self.downloadTracker[index] = false
            }
            return nil
        }
    }
}

extension CatsCache {
    subscript(_ index: Int) -> UIImage? {
        get {
            return catImage(at: index)
        }
    }
}
