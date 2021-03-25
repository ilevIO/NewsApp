//
//  NewsScreen+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import UIKit
import WebKit

class NewsLoader: SubscriberObject {
    var subscriptionId: Int = UUID().hashValue
    
    let loadingLock = NSLock()
    var loadedPages: Set<Int> = .init()
    ///In progress
    var loadingPages: Set<Int> = .init()
    
    var loadingFor: Int = 0
    var loaded: Int = 0
    
    func loadNext(currentLoaded: Int, for timePeriod: ClosedRange<Date>, completion: ((FetchedEverything?) -> Void)?) {
        loadingLock.lock()
        defer {
            loadingLock.unlock()
        }
        //guard currentLoaded >= loaded else { return }
        Current.api.news.getEverything(.init(from: timePeriod.lowerBound, to: timePeriod.upperBound)) { news in
            completion?(news)
        }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })
    }
}

extension NewsScreen {
    class Presenter {
        weak var view: NewsScreenView?
        
        private(set) var subscriptionId = UUID().hashValue
        var news: [ArticleModel] = []
        
        var newsLoader = NewsLoader()
        
        var currentPeriod: ClosedRange<Date> = {
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!...Date()
        }()
        
        func refresh() {
            currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: Date())!...Date()
            news = []
            //self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
            newsLoader.loadNext(currentLoaded: 0, for: currentPeriod) { [weak self] news in
                guard let self = self, let news = news else { return }
                
                if !news.articles.isEmpty {
                    self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
                    self.news.append(contentsOf: news.articles.compactMap({ ArticleModel(with: $0) }))
                }
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self.view?.update(with: self.news, forced: true)
                    }
                }
            }
        }
        
        func searchQueryChanged(to query: String) {
        }
        func newsCellTapped(at index: IndexPath) {
            guard let _url = news[index.item].url, let url = URL(string: _url) else { return }
            let webView = WKWebView()
            let vc = UIViewController()
            vc.view.fill(with: webView)
            webView.load(.init(url: url))
            Current.root?.rootView.navigationController?.pushViewController(vc, animated: true)
        }
        
        func loadNext() {
            newsLoader.loadNext(currentLoaded: news.count, for: currentPeriod) { [weak self] news in
                guard let self = self, let news = news else { return }
                let newArticles = news.articles.filter { fetchedArticle in
                    !self.news.contains {
                        fetchedArticle.url == $0.url
                    }
                }
                if !news.articles.isEmpty {
                    self.currentPeriod = Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.lowerBound)!...Calendar.current.date(byAdding: .day, value: -1, to: self.currentPeriod.upperBound)!
                    self.news.append(contentsOf: newArticles.compactMap({ ArticleModel(with: $0) }))
                }
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self.view?.update(with: self.news, forced: false)
                    }
                }
            }
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
