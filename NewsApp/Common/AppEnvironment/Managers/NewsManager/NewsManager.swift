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
        if let result = Current.localStorage.load(entityName: "LocalCategoryResult", predicate: .init(format: "category == %@", category))?
            .first {
            guard let articleUrls = (result.value(forKey: "articleUrls") as? String)?.split(separator: ",")
                    .map({ String($0) /*as? String*/ })
            else { return nil }
            guard let managedArticles = Current.localStorage.load(
                entityName: "LocalArtile",
                predicate: .init(format: "url IN %@", articleUrls)
            ) else { return nil }
            
            let articles = managedArticles.map({
                ArticleDTO(
                    source: ($0.value(forKey: "sourceName") as? String)
                        .flatMap({ NewsSource(id: "0", name: $0) }),
                    author: $0.value(forKey: "author") as? String,
                    title: $0.value(forKey: "title") as? String,
                    description: $0.value(forKey: "descriptionText") as? String,
                    url: $0.value(forKey: "url") as? String,
                    urlToImage: $0.value(forKey: "urlToImage") as? String,
                    publishedAt: $0.value(forKey: "publishedAt") as? String,
                    content: $0.value(forKey: "content") as? String)
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
                "category": category,
                "articleUrls": result.articles.compactMap({ $0.url }).joined(separator: ","),
                "lastAccess": Date()],
            to: "LocalCategoryResult"
        )
        result.articles.forEach({
            Current.localStorage.save(
                entityFields: [
                    "category": category,
                    "author": $0.author,
                    "sourceName": $0.source?.name,
                    "urlToImage": $0.urlToImage,
                    "descriptionText": $0.description,
                    "content": $0.content,
                    "url": $0.url,
                    "title": $0.title,
                    "lastAccess": Date()
                ],
                to: "LocalArticle"
            )
        })
        
    }
    
    func getCachedResult(forCategory category: String) -> Result? {
        guard let result = cache.value(forKey: category) ?? getLocalStored(forCategory: category) else { return nil }
        return result
    }
    
    func getEverything(_ params: Endpoints.News.GetEverything.Parameters, _ completion: ((FetchedEverything?) -> Void)?) -> URLSessionTask? {
        //let urlKey = key//.hasPrefix("http") ? key : baseImageUrl.absoluteString.appending(key)
        if let category = params.category {
            if let result = getCachedResult(forCategory: category) {
                completion?(result)
                return nil
            }
            self.lock.execute {
                if let _ = requests[category] {
                    requests[category]?.append(completion)
                } else {
                    requests[category] = [completion]
                }
            }
        }
        //guard let url = URL(string: urlKey) else { completion?(nil); return nil }
        
  
        return Current.api.news.getEverything(params) { [weak self] fetchedResult in
            if let result = fetchedResult {
                if let category = params.category {
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
    
    /*func setImage(_ image: UIImage?, forKey key: String) {
        if let image = image, let data = image.pngData() { cache.insert(data, forKey: key) }
        else { cache.removeValue(forKey: key) }
    }*/
}
