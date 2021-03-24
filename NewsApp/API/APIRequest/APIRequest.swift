//
//  APIRequest.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import Alamofire

public protocol APIRequest {
    associatedtype Response: Decodable
    associatedtype Parameters: Encodable
    
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters { get }
    var encoder: ParameterEncoder { get }
}

extension APIRequest {
    public var headers: HTTPHeaders? { nil }
    public var isAuthorized: Bool { true }
    
    public var encoder: ParameterEncoder {
        switch httpMethod {
        case .get, .delete, .head:
            return CleanParameterEncoder(encoder: URLEncodedFormEncoder(dateEncoding: .iso8601), destination: .queryString)
        default:
            return JSONParameterEncoder(
                encoder: {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    return encoder
                }()
            )
                    
        }
    }
}


extension APIRequest where Parameters == VoidParameters {
    public var parameters: Parameters { .none }
}
