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
        
        var sections = ["Business", "Sport", "Entertainment", "World", "Belarus"]//["Apple", "IT", "Belarus", "Cocoa", "iOS"]
        
        private(set) var subscriptionId = UUID().hashValue
        var news: [String: NewsSectionModel] = [:]
        
        var newsLoader = NewsLoader()
        
        var currentPeriod: [String: ClosedRange<Date>] = [:]
        var lastPeriod: ClosedRange<Date> {
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!...Date()
        }
        
        var query = ""
        var lastQueryTask: Cancellable?
        
        func refresh(for category: String) {
            let currentCategoryPeriod = lastPeriod
            currentPeriod[category] = currentCategoryPeriod
            news[category] = .init(name: category, articles: [])
            //self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
            newsLoader.loadNext(
                query: query.isEmpty ? nil : query,
                currentLoaded: 0,
                for: query.isEmpty ? currentCategoryPeriod : nil,
                category: query.isEmpty ? category : nil) { [weak self] news in
                guard let self = self, let news = news else { return }
                
                if !news.articles.isEmpty {
                    let currentCategoryPeriod = self.currentPeriod[category] ?? self.lastPeriod
                    self.currentPeriod[category] = Calendar.current.date(byAdding: .day, value: -1, to: currentCategoryPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: currentCategoryPeriod.upperBound)!
                    /*self.news.append(
                        contentsOf:
                            news.articles.compactMap {
                                ArticleCellModel(model: ArticleModel(with: $0), isExpanded: false)
                            }
                    )*/
                    self.news[category]?.articles.append(
                        contentsOf:
                            news.articles.compactMap {
                                ArticleCellModel(model: ArticleModel(with: $0), isExpanded: false)
                            }
                    )
                }
                DispatchQueue.main.async {
                    //UIView.animate(withDuration: 0.3) {
                        self.view?.update(with: self.news[category]?.articles ?? [], for: category, forced: true)
                    //}
                }
            }
        }
        
        func searchQueryChanged(to query: String) {
            lastQueryTask?.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.query = query
                self.refresh(for: "")
            }
        }
        
        func newsCellTapped(at index: IndexPath, in category: String) {
            guard let _url = news[category]?.articles[index.item].model.url, let url = URL(string: _url) else { return }
            let webView = WKWebView()
            let vc = UIViewController()
            vc.view.fill(with: webView)
            webView.load(.init(url: url))
            Current.root?.rootView.navigationController?.pushViewController(vc, animated: true)
        }
        
        func loadNext(category: String) {
            if news[category] == nil {
                if let result = Current.news.getCachedResult(forCategory: category) {
                    /*self.news[category] = .init(
                        name: category,
                        articles: result
                            .articles
                            .compactMap {
                                ArticleCellModel(model: ArticleModel(with: $0), isExpanded: false)
                            }
                    )*/
                    DispatchQueue.main.async {
                        self.view?.update(
                            with: result.articles.compactMap {  ArticleCellModel(model: ArticleModel(with: $0), isExpanded: false) },
                            for: category,
                            forced: false
                        )
                    }
                }
            }
            
            let currentPeriod = self.currentPeriod[category] ?? lastPeriod
            self.currentPeriod[category] = currentPeriod
            self.news[category] = self.news[category] ?? .init(name: category, articles: [])
            guard currentPeriod.lowerBound.distance(to: .init()) < 7 * 24 * 60 * 60 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                //Change of self.currentPeriod indicates that it has been loaded for currend period
                guard let self = self, currentPeriod == self.currentPeriod[category] else { return }
                
                self.newsLoader.loadNext(
                    query: self.query.isEmpty ? nil : self.query,
                    currentLoaded: self.news[category]?.articles.count ?? 0,
                    for: currentPeriod,
                    category: self.query.isEmpty ? category : nil
                ) { [weak self] news in
                    guard let self = self else { return }
                    guard let news = news else {
                        //Show error message
                        DispatchQueue.main.async {
                            self.view?.update(with: [], for: category, forced: false)
                        }
                        return
                    }
                    let newArticles = news.articles.filter { fetchedArticle in
                        !self.news[category]!.articles.contains {
                            fetchedArticle.url == $0.model.url
                        }
                    }
                    let currentPeriod = self.currentPeriod[category] ?? self.lastPeriod
                    if !newArticles.isEmpty {
                        self.currentPeriod[category] = Calendar.current.date(byAdding: .day, value: -1, to: currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: currentPeriod.upperBound)!
                        self.news[category]?.articles.append(
                            contentsOf: newArticles
                                .compactMap {
                                    ArticleCellModel(
                                        model: ArticleModel(with: $0),
                                        isExpanded: false)
                                }
                        )
                    }
                    DispatchQueue.main.async {
                        self.view?.update(with: self.news[category]!.articles, for: category, forced: false)
                    }
                }
            }
        }
        
        func scrollDidReachBounds(in category: String) {
            loadNext(category: category)
        }
        
        func fetchNews(for category: String) {
            scrollDidReachBounds(in: category)
            /*let sevenDaysBack = Calendar.current.date(byAdding: .day, value: -7, to: .init())!
            Current.api.news.getEverything(
                .init(
                    q: "apple",
                    qInTitle: nil,
                    sources: nil,
                    domains: nil,
                    excludeDomains: nil,
                    from: sevenDaysBack,
                    to: nil,
                    language: "en",
                    sortBy: nil,
                    pageSize: nil,
                    page: nil,
                    country: nil,
                    category: nil
                )
            ) { [weak self] news in
                guard let self = self, let news = news else { return }
                self.news = news.articles.map({ ArticleModel(with: $0) })
                DispatchQueue.main.async {
                    self.view?.update()
                }
            }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })*/
        }
    }
}

extension NewsScreen.Presenter: SubscriberObject { }
