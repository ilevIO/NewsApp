//
//  APIRequestBuilder.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public class APIRequestBuilder {
    public let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func build<APIRequestType: APIRequest>(_ request: APIRequestType) throws -> URLRequest {
        let urlRequest = try createRequest(request)
        
        guard (type(of: request.parameters) != VoidParameters.self)
        else { return urlRequest }
        
        return try request.encoder.encode(request.parameters, into: urlRequest)
    }
    
    private func createRequest<APIRequestType: APIRequest>(_ request: APIRequestType) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(request.path)
        var urlRequest = try URLRequest(url: url, method: request.httpMethod, headers: request.headers)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.timeoutInterval = 10.0
        if urlRequest.headers["Content-Type"] == nil {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }
}
