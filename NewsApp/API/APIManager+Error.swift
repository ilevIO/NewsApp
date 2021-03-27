//
//  APIManager+Error.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public struct APIError: Decodable, Error {
    public var timestamp: String?
    public var status: String
    public var message: String?
    public var type: String?
}

public extension APIManager {
    func dataContainingError(data: Data) -> APIError? {
        return try? JSONDecoder().decode(APIError.self, from: data)
    }
    
    func processResponse(data: Data?, response: URLResponse, error: Error?, successCompletion: (Data?, URLResponse?, Error?) -> Void) {
        
    }
    
    func handleError(data: Data?, response: URLResponse?, error: Error?, failCompletion: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> APIError? {
        if let response = (response as? HTTPURLResponse) {
            if response.statusCode == 200 {
                return nil
            } else {
                if let data = data, !data.isEmpty, let error = dataContainingError(data: data) {
                    failCompletion?(nil, response, error)
                    return error
                } else {
                    let error = APIError(timestamp: nil, status: "\(response.statusCode)", message: response.description, type: response.mimeType)
                    failCompletion?(nil, response, error)
                    return error
                }
            }
        } else {
            if let data = data, !data.isEmpty, let error = dataContainingError(data: data) {
                return error
            } else if let error = error as? URLError {
                return APIError(timestamp: nil, status: "\(error.errorCode)", message: error.localizedDescription, type: error.failingURL?.lastPathComponent)
            }
        }
        return nil
    }
    
}
