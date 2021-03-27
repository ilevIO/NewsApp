//
//  AppEnvironment.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
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

let _apiManager = APIManager(
    authorization: NewsAuthorization(),
    baseUrl: URL(string: "https://newsapi.org/v2")!
)

struct AppEnvironment {
    var api: APIProvider
    var image: ImageProvider
    var localStorage: LocalStorageManager
    var news: NewsManager
    var root: Root.Presenter?
}

extension AppEnvironment {
    static var `default`: Self {
        AppEnvironment(
            api: .mock,
            image: .default,
            localStorage: .init(),
            news: .init()
        )
    }
}

var Current: AppEnvironment = .default
