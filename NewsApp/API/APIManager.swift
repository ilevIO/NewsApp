//
//  APIManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public protocol AuthorizationProtocol {
    func setAccessToken(_ accessToken: String)
    func accessToken() -> String?
    
    var httpField: String? { get }
}

public class APIManager {
    public let apiClient: APIClient
    
    public init(authorization: AuthorizationProtocol, baseUrl: URL) {
        self.apiClient = APIClient(authorization: authorization, baseUrl: baseUrl)
    }
}
