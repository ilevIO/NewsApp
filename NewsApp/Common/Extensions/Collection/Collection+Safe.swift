//
//  Collection+Safe.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
