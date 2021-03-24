//
//  CleanParameterEncoder.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import Alamofire

public class CleanParameterEncoder: URLEncodedFormParameterEncoder {
    public override func encode<Parameters>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest where Parameters : Encodable {
        var request = try super.encode(parameters, into: request)
        request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "=")
        )
        return request
    }
}
