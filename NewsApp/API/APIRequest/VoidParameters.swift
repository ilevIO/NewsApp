//
//  VoidParameters.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public enum EmptyParameters: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(from: decoder)
    }
    public func encode(to encoder: Encoder) throws {}
}

public typealias VoidParameters = Optional<EmptyParameters>
