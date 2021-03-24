//
//  APIClient.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public class APIClient {
    private let session: URLSession
    public let requestBuilder: APIRequestBuilder
    var authorization: AuthorizationProtocol
    
    public func request<T: APIRequest>(_ request: T, completion: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)? = nil) -> URLSessionTask? {
        do {
            var request = try requestBuilder.build(request)
            
            if let token = authorization.accessToken() {
                request.addValue("\(token)", forHTTPHeaderField: authorization.httpField ?? "Authorization")
            }
            
            let task = session.dataTask(with: request) { data, response, error in
                completion?(data, response, error)
            }
            task.resume()
            return task
        } catch {
            //fatalError("")
        }
        return nil
    }
    
    public init(authorization: AuthorizationProtocol, baseUrl: URL) {
        self.session = .shared
        self.requestBuilder = APIRequestBuilder(baseURL: baseUrl)
        self.authorization = authorization
    }
}
