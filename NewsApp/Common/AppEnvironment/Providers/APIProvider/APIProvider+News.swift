//
//  APIProvider+News.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

struct FetchedEverything {
    var totalResults: Int
    var articles: [ArticleDTO]
    
    init?(with response: Endpoints.News.GetEverything.Response) {
        guard let _totalResults = response.totalResults /*, let totalResults = _totalResults*/ else { return nil }
        self.totalResults = _totalResults
        self.articles = response.articles ?? []
    }
}

struct APITask<Parameters: Encodable, Result> {
    var parameters: Parameters?
    var completion: ((Result?) -> Void)?
}

extension APIProvider {
    struct NewsGroup: APIProviderGroup {
        var getEverything: ((Endpoints.News.GetEverything.Parameters, ((FetchedEverything?) -> Void)?) -> URLSessionTask?)//(APITask<Endpoints.News.GetEverything.Parameters, ((FetchedEverything?) -> Void)?>) -> URLSessionTask? //
        
        init(getEverything: @escaping ((Endpoints.News.GetEverything.Parameters, ((FetchedEverything?) -> Void)?) -> URLSessionTask?)) {
            self.getEverything = getEverything
        }
    }
}

extension APIProvider.NewsGroup {
    static var `default` = Self.init(
        getEverything: { params, completion in
            Self.apiManager.getEverything(parameters: params) { result, error in
                if let result = result {
                    completion?(FetchedEverything(with: result))
                } else {
                    //show error
                    completion?(nil)
                }
            }
        }
    )
    
    static var mock = Self.init(getEverything: { params, completion in
        guard let path = Bundle.main.path(forResource: "newsmock", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        
        var result = try! JSONDecoder().decode(Endpoints.News.GetEverything.Response.self, from: data)
        if let page = params.page, let pageSize = params.pageSize {
            result.articles = result.articles?
                .enumerated()
                .filter {
                    ((page - 1) * pageSize..<(page * pageSize))
                        .contains($0.offset)
                }
                .map { $0.element }
        }
        completion?(FetchedEverything(with: result))
        return nil
    })
}

