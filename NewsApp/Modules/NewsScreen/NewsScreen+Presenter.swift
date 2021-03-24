//
//  NewsScreen+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

extension NewsScreen {
    class Presenter: SomePresenter {
        weak var coordinator: CoordinatorProtocol?
        
        weak var view: NewsScreenView?
        
        private(set) var subscriptionId = UUID().hashValue
        var news: [Article] = []
        
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
                self.news = news.articles
                DispatchQueue.main.async {
                    self.view?.update()
                }
            }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })
        }
    }
}

extension NewsScreen.Presenter: SubscriberObject { }
