//
//  NSLock.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

extension NSLock {
    @discardableResult
    func execute<T>(code closure: () -> T) -> T {
        lock()
        defer { unlock() }
        return closure()
    }
    
}
