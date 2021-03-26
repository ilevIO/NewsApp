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

class NewsLoader: SubscriberObject {
    var subscriptionId: Int = UUID().hashValue
    
    func checkLocalStorage() {
        //Exctract everything from core data
    }
    
    func storeLocally(articles: [ArticleDTO]) {
         //core data save object
    }
    
    func loadNext(query: String? = nil, currentLoaded: Int, for timePeriod: ClosedRange<Date>, completion: ((FetchedEverything?) -> Void)?) {
        if currentLoaded == 0 {
            checkLocalStorage()
        }
        Current.api.news.getEverything(.init(q: query, from: timePeriod.lowerBound, to: timePeriod.upperBound)) { news in
            if let news = news {
                
            }
            completion?(news)
        }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })
    }
}

extension NewsScreen {
    class Presenter {
        weak var view: NewsScreenView?
        
        private(set) var subscriptionId = UUID().hashValue
        var news: [ArticleCellModel] = []
        
        var newsLoader = NewsLoader()
        
        var currentPeriod: ClosedRange<Date> = {
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!...Date()
        }()
        
        var query = ""
        var lastQueryTask: Cancellable?
        
        func refresh() {
            currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: Date())!...Date()
            news = []
            //self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
            newsLoader.loadNext(query: query.isEmpty ? nil : query, currentLoaded: 0, for: currentPeriod) { [weak self] news in
                guard let self = self, let news = news else { return }
                
                if !news.articles.isEmpty {
                    self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
                    self.news.append(
                        contentsOf:
                            news.articles.compactMap {
                                ArticleCellModel(model: ArticleModel(with: $0), isExpanded: false)
                            }
                    )
                }
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self.view?.update(with: self.news, forced: true)
                    }
                }
            }
        }
        
        func searchQueryChanged(to query: String) {
            lastQueryTask?.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.query = query
                self.refresh()
            }
        }
        
        func newsCellTapped(at index: IndexPath) {
            guard let _url = news[index.item].model.url, let url = URL(string: _url) else { return }
            let webView = WKWebView()
            let vc = UIViewController()
            vc.view.fill(with: webView)
            webView.load(.init(url: url))
            Current.root?.rootView.navigationController?.pushViewController(vc, animated: true)
        }
        
        func loadNext() {
            let currentPeriod = self.currentPeriod
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self, currentPeriod == self.currentPeriod else { return }
                self.newsLoader.loadNext(query: self.query.isEmpty ? nil : self.query, currentLoaded: self.news.count, for: self.currentPeriod) { [weak self] news in
                    guard let self = self, let news = news else { return }
                    let newArticles = news.articles.filter { fetchedArticle in
                        !self.news.contains {
                            fetchedArticle.url == $0.model.url
                        }
                    }
                    if !news.articles.isEmpty {
                        self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
                        self.news.append(contentsOf: newArticles.compactMap {  ArticleCellModel(model: ArticleModel(with: $0), isExpanded: false) })
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.3) {
                                self.view?.update(with: self.news, forced: false)
                            }
                        }
                    }
                    
                }
            }
        }
        
        func searchValueChanged(string: String) {
            
        }
        
        func scrollDidReachBounds(withOffset offset: CGFloat) {
            loadNext()
        }
        
        func fetchNews() {
            scrollDidReachBounds(withOffset: 0)
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
