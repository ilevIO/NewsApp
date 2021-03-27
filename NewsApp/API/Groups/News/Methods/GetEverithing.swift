//
//  GetNews.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Alamofire
import Foundation

public extension Endpoints.News {
    struct GetEverything: APIRequest {
        
        public var path: String { "everything" }
        public var httpMethod: HTTPMethod = .get
        public var parameters: Parameters
        
        public init(parameters: Parameters) {
            self.parameters = parameters
        }
    }
}

public extension Endpoints.News.GetEverything {
    struct Parameters: Codable {
        public var q: String? = nil
        public var qInTitle: String? = nil
        public var sources: [String]? = nil
        public var domains: [String]? = nil
        public var excludeDomains: [String]? = nil
        public var from: Date? = nil
        public var to: Date? = nil
        public var language: String? = nil
        public var sortBy: GetNewsSortMethod? = nil
        public var pageSize: Int? = nil
        public var page: Int? = nil
        public var country: String? = nil
        public var category: String? = nil
    }
}
    
public extension Endpoints.News.GetEverything {
    struct Response: Codable {
        public var status: GetNewsStatus?
        public var totalResults: Int?
        public var articles: [ArticleDTO]?
    }
}
