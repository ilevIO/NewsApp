//
//  APIProvider.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

struct APIProvider {
    let subscriptions = CancellablesManager<URLSessionTask>()
    
    var news: NewsGroup
}

extension APIProvider {
    static var `default`: APIProvider = .init(news: .default)
    static var `mock`: APIProvider = .init(news: .mock)
}
