//
//  NewsScreen+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

extension NewsScreen {
    class Presenter {
        weak var view: NewsScreenView?
        
        private(set) var subscriptionId = UUID().hashValue
        var news: [ArticleModel] = []
        
        func fetchNews() {
            let sevenDaysBack = Calendar.current.date(byAdding: .day, value: -7, to: .init())!
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
                    pageSize: 10,
                    page: 1,
                    country: nil,
                    category: nil
                )
            ) { [weak self] news in
                guard let self = self, let news = news else { return }
                self.news = news.articles.map({ ArticleModel(with: $0) })
                DispatchQueue.main.async {
                    self.view?.update()
                }
            }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })
        }
    }
}

extension NewsScreen.Presenter: SubscriberObject { }
