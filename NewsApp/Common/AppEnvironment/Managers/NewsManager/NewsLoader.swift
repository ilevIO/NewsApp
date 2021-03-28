//
//  NewsLoader.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation

class NewsLoader: SubscriberObject {
    var subscriptionId: Int = UUID().hashValue
    
    ///- Parameter query: query for title
    ///- Parameter category: used as q parameter
    func loadNext(query: String? = nil,
                  for timePeriod: ClosedRange<Date>?,
                  category: String? = nil,
                  completion: ((FetchedEverything?) -> Void)?
    ) {
        Current.news.getEverything(
            .init(
                q: category,
                qInTitle: query,
                from: timePeriod?.lowerBound, to: timePeriod?.upperBound,
                sortBy: .publishedAt
            )
        ) { news in
            completion?(news)
        }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })
    }
    
    deinit {
        Current.api.subscriptions.cancelAndRelease(from: self)
    }
}

