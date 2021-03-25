//
//  NewsScreen+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import WebKit

class SimpleStackView: UIView {
    var arrangedSubviews: [UIView] = .init()
    var spacing: CGFloat = 4
    var axis: NSLayoutConstraint.Axis = .vertical
    func addArrangedSubview(_ subview: UIView) {
        let maxAnchor = arrangedSubviews.last?.bottomAnchor ?? self.topAnchor
        arrangedSubviews.append(subview)
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.attach(to: self, left: 0, right: 0)
        subview.topAnchor.constraint(equalTo: maxAnchor, constant: spacing).isActive = true
    }
    
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach({
            $0.removeAllConstraints()
            $0.removeFromSuperview()
        })
        arrangedSubviews = []
    }
}

extension NewsScreen {
    class Presenter {
        weak var view: NewsScreenView?
        
        private(set) var subscriptionId = UUID().hashValue
        var news: [ArticleModel] = []
        
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
