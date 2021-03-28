//
//  NewsScreen+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import UIKit
import WebKit
import Combine

extension NewsScreen {
    class Presenter {
        weak var view: NewsScreenView?
        
        //Seconds to wait before updating
        let loadingBreak: TimeInterval = 1
        
        var newsLoader = NewsLoader()
        ///Default sections. Are to be made modifiable in future
        let categories = ["Belarus", "Business", "Sport", "Entertainment", "World", "Apple"]
        ///Max number of days to load articles for
        let loadArticlesDayLimit: TimeInterval = 7
        ///Articles by their category name
        var news: [String: NewsSectionModel] = [:]
        
        ///Period currently to be loaded for category
        var currentPeriod: [String: ClosedRange<Date>] = [:]
        var loadingPeriods: [String: ClosedRange<Date>] = [:]
        ///From-yesterday to now range
        var lastPeriod: ClosedRange<Date> {
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!...Date()
        }
        
        ///Indicates whether to perform search request of filter loaded
        var shouldPerformGlobalSearch = false
        var query = ""
        var lastQueryTask: Cancellable?
        
        //Queue for news and periods synchronization
        let newsQueue = DispatchQueue(label: "news_scrceen.presenter.news")
        
        ///Resets period for the category and loads articles. Returns flag if refresh is allowed
        @discardableResult
        func refresh(for category: String?) -> Bool {
            //Not reloading when is searching locally
            guard query.isEmpty || shouldPerformGlobalSearch else { return false }
            
            let currentCategoryPeriod = lastPeriod
            if let category = category {
                newsQueue.sync {
                    loadingPeriods.removeValue(forKey: category)
                    currentPeriod[category] = currentCategoryPeriod
                    news[category] = .init(name: category, articles: [])
                }
            }
            //Ignore category and period if is searching
            newsLoader.loadNext(
                query: query.isEmpty ? nil : query,
                for: query.isEmpty ? currentCategoryPeriod : nil,
                category: query.isEmpty ? category : nil) { [weak self] news in
                guard let self = self else { return }
                
                guard let news = news else {
                    self.newsQueue.sync {
                        let news = category.flatMap({ self.news[$0]?.articles }) ?? []
                        DispatchQueue.main.async {
                            self.view?.update(with: news, for: category)
                        }
                    }
                    return
                }
                
                let articles: [ArticlePresentationModel] = news.articles.compactMap {
                    ArticlePresentationModel(model: ArticleModel(with: $0), isExpanded: false)
                }
                
                //Change current ccategory period only if news received
                if let category = category, !news.articles.isEmpty {
                    
                    self.newsQueue.sync {
                        let currentCategoryPeriod = self.currentPeriod[category] ?? self.lastPeriod
                        //Change period to previous day
                        self.currentPeriod[category] = Calendar.current.date(byAdding: .day, value: -1, to: currentCategoryPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: currentCategoryPeriod.upperBound)!
                        self.news[category]?.articles.append(contentsOf: articles)
                    }
                }
                
                DispatchQueue.main.async {
                    self.view?.update(with: articles, for: category)
                }
            }
            return true
        }
        
        //MARK: - Handlers
        func searchQueryChanged(to query: String) {
            if self.shouldPerformGlobalSearch {
                lastQueryTask?.cancel()
                DispatchQueue.main.asyncAfter(deadline: .now() + loadingBreak) {
                    self.query = query
                    self.refresh(for: nil)
                }
            } else {
                newsQueue.sync {
                    news.values.forEach({ category in
                        //Update with everythin if query is empty
                        let filteredArticles = query.isEmpty
                            ? category.articles
                            : category.articles.filter({
                                $0.model.title.lowercased().contains(query.lowercased())
                            }
                            )
                        DispatchQueue.main.async {
                            self.view?.update(with: filteredArticles, for: category.name)
                        }
                    })
                }
            }
        }
        
        func newsCellTapped(at index: IndexPath, in category: String) {
            newsQueue.sync {
                guard let _url = news[category]?.articles[index.item].model.url, let url = URL(string: _url) else { return }
                
                DispatchQueue.main.async {
                    let webViewController = WebViewController(request: .init(url: url))
                    Current.root?.navigate(to: webViewController)
                }
            }
        }
        
        //MARK: - News loading
        func loadCachedArticles(for category: String) {
            if let result = Current.news.getCachedResult(forCategory: category) {
                DispatchQueue.main.async {
                    self.view?.update(
                        with: result.articles.compactMap {
                            ArticlePresentationModel(
                                model: ArticleModel(with: $0),
                                isExpanded: false
                            )
                        },
                        for: category
                    )
                }
            }
        }
        
        func loadNext(category: String, completion: (() -> Void)? = nil) {
            newsQueue.sync {
                //Use cached articles as placeholders until relevant are being fetched if it is the first time loading category
                if news[category] == nil {
                    loadCachedArticles(for: category)
                }
                //Period to be loaded
                let currentPeriod = self.currentPeriod[category] ?? lastPeriod
                
                guard loadingPeriods[category] != currentPeriod else {
                    completion?()
                    return
                }
                loadingPeriods[category] = currentPeriod
                self.currentPeriod[category] = currentPeriod
            
                self.news[category] = self.news[category] ?? .init(name: category, articles: [])
            
                guard currentPeriod.lowerBound.isWithinPeriod(days: loadArticlesDayLimit) else {
                    completion?()
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + loadingBreak) { [weak self] in
                    //Change of self.currentPeriod indicates that it has been loaded for currend period
                    guard let self = self, currentPeriod == self.currentPeriod[category] else {
                        completion?()
                        return
                    }
                    
                    self.newsLoader.loadNext(
                        query: self.query.isEmpty ? nil : self.query,
                        for: currentPeriod,
                        category: self.query.isEmpty ? category : nil
                    ) { [weak self] news in
                        
                        guard let self = self else { return }
                        guard let news = news else {
                            //Show error message
                            DispatchQueue.main.async {
                                completion?()
                                self.view?.update(with: [], for: category)
                            }
                            return
                        }
                        
                        self.newsQueue.sync {
                            let newArticles = news.articles
                                .filter { fetchedArticle in
                                    !self.news[category]!.articles.contains {
                                        fetchedArticle.url == $0.model.url
                                    }
                                }
                                .compactMap {
                                    ArticlePresentationModel(
                                        model: ArticleModel(with: $0),
                                        isExpanded: false)
                                }
                            
                            let currentPeriod = self.currentPeriod[category] ?? self.lastPeriod
                            
                            if !newArticles.isEmpty {
                                self.currentPeriod[category] = Calendar.current.date(byAdding: .day, value: -1, to: currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: currentPeriod.upperBound)!
                            }
                            
                            self.news[category]?.articles.append(contentsOf: newArticles)
                            let news = self.news
                            
                            guard let categoryArticles = news[category]?.articles else { return }
                            completion?()
                            DispatchQueue.main.async {
                                self.view?.update(with: categoryArticles, for: category)
                            }
                        }
                    }
                }
            }
        }
        
        func scrollDidReachBounds(in category: String) {
            loadNext(category: category)
        }
        
        func fetchNews(for category: String, completion: (() -> Void)? = nil) {
            loadNext(category: category, completion: completion)
        }
    }
}
