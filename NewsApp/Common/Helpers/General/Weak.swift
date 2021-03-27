//
//  Weak.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import Foundation

struct Weak<T: AnyObject> {
    weak var value: T?
}
