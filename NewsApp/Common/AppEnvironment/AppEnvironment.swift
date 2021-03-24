//
//  AppEnvironment.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

class NewsAuthorization: AuthorizationProtocol {
    static var apiKey: String? = newsAPIKey
    
    func setAccessToken(_ accessToken: String) {
        Self.apiKey = accessToken
    }
    
    func accessToken() -> String? {
        Self.apiKey
    }
}

let _apiManager = APIManager(
    authorization: NewsAuthorization(),
    baseUrl: URL(string: "https://newsapi.org/v2")!
)

struct AppEnvironment {
    var api: APIProvider
    
    var root: Root.Presenter?
}

extension AppEnvironment {
    static var `default`: Self {
        AppEnvironment(
            api: APIProvider()
        )
    }
}

var Current: AppEnvironment = .default
