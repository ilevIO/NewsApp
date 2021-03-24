//
//  APIProviderGroup.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

protocol APIProviderGroup {}

extension APIProviderGroup {
     static var apiManager: APIManager { _apiManager }
}
