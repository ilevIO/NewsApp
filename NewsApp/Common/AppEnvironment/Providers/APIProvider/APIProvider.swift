//
//  APIProvider.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

struct APIProvider {
    let subscriptions = CancellablesManager<URLSessionTask>()
}

