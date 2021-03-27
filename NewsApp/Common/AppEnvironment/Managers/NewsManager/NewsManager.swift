//
//  NewsManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation

class NewsManager {
    typealias Result = FetchedEverything

    var cache = Cache<String, Result>()
    var lock = NSLock()
    var requests: [String: [((Result?) -> Void)?]] = [:]
    
    func getLocalStored(forCategory category: String) -> Result? {
        if let result = Current.localStorage.load(
            entityName: CoreDataEntities.localCategoryResult,
            predicate: .init(format: "\(CoreDataLocalCategoryResult.category) == %@", category)
        )?.first {
            guard let articleUrls = (result.value(forKey: CoreDataLocalCategoryResult.articleUrls) as? String)?.split(separator: ",")
                    .map({ String($0) })
            else { return nil }
            
            guard let managedArticles = Current.localStorage.load(
                entityName: CoreDataEntities.localArticle,
                predicate: .init(format: "\(CoreDataLocalArticle.url) IN %@", articleUrls)
            ) else { return nil }
            
            let articles = managedArticles.map({
                ArticleDTO(
                    source: ($0.value(forKey: CoreDataLocalArticle.sourceName) as? String)
                        .flatMap({ NewsSource(id: "0", name: $0) }),
                                      author: $0.value(forKey: CoreDataLocalArticle.author) as? String,
                                                       title: $0.value(forKey: CoreDataLocalArticle.title) as? String,
                    description: $0.value(forKey: CoreDataLocalArticle.descriptionText) as? String,
                    url: $0.value(forKey: CoreDataLocalArticle.url) as? String,
                    urlToImage: $0.value(forKey: CoreDataLocalArticle.urlToImage) as? String,
                    publishedAt: $0.value(forKey: CoreDataLocalArticle.publishedAt) as? String,
                    content: $0.value(forKey: CoreDataLocalArticle.content) as? String)
            })
            
            let fetchedResult = Result(with: .init(status: .ok, totalResults: articles.count, articles: articles))
            self.insertResult(fetchedResult, forKey: category)
            return fetchedResult
        }
        return nil
    }
    
    func saveResultLocally(result: Result, category: String) {
        Current.localStorage.save(
            entityFields: [
                CoreDataLocalCategoryResult.category: category,
                CoreDataLocalCategoryResult.articleUrls: result.articles.compactMap({ $0.url }).joined(separator: ","),
                CoreDataLocalCategoryResult.lastAccess: Date()],
            to: CoreDataEntities.localCategoryResult,
            primaryKey: .init(key: CoreDataLocalCategoryResult.category, value: category)
        )
        result.articles.forEach({
            Current.localStorage.save(
                entityFields: [
                    CoreDataLocalArticle.category: category,
                    CoreDataLocalArticle.author: $0.author,
                    CoreDataLocalArticle.sourceName: $0.source?.name,
                    CoreDataLocalArticle.urlToImage: $0.urlToImage,
                    CoreDataLocalArticle.descriptionText: $0.description,
                    CoreDataLocalArticle.content: $0.content,
                    CoreDataLocalArticle.url: $0.url,
                    CoreDataLocalArticle.title: $0.title,
                    CoreDataLocalArticle.publishedAt: $0.publishedAt,
                    CoreDataLocalArticle.lastAccess: Date(),
                ],
                to: CoreDataEntities.localArticle,
                primaryKey: $0
                    .url.flatMap {
                        PrimaryKey(key: CoreDataLocalArticle.url, value: $0)
                    }
            )
        })
        
    }
    
    func getCachedResult(forCategory category: String) -> Result? {
        guard let result = cache.value(forKey: category) ?? getLocalStored(forCategory: category) else { return nil }
        return result
    }
    
    func getEverything(_ params: Endpoints.News.GetEverything.Parameters, _ completion: ((FetchedEverything?) -> Void)?) -> URLSessionTask? {
        
        return Current.api.news.getEverything(params) { [weak self] fetchedResult in
            if let result = fetchedResult {
                if let category = params.q {
                    self?.insertResult(result, forKey: category)
                    self?.saveResultLocally(result: result, category: category)
                    self?.lock.execute {
                        self?.requests[category]?.forEach({ $0?(result) })
                        self?.requests.removeValue(forKey: category)
                    }
                }
                completion?(result)
            } else {
                completion?(nil)
            }
        }
    }
    
    @discardableResult
    private func insertResult(_ result: Result?, forKey key: String) -> Result? {
        if let result = result {
            cache.insert(result, forKey: key)
        }
        return result
    }
}
