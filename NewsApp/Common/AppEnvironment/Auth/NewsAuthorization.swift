//
//  NewsAuthorization.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import Foundation

class NewsAuthorization: AuthorizationProtocol {
    static var apiKey: String? = newsAPIKey
    var httpField: String? { "x-api-key" }
    
    func setAccessToken(_ accessToken: String) {
        Self.apiKey = accessToken
    }
    
    func accessToken() -> String? {
        Self.apiKey
    }
}
