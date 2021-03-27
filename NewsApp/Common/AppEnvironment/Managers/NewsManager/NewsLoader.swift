//
//  NewsLoader.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation

class NewsLoader: SubscriberObject {
    var subscriptionId: Int = UUID().hashValue
    
    deinit {
        Current.api.subscriptions.cancelAndRelease(from: self)
    }
    
    func loadNext(query: String? = nil, currentLoaded: Int, for timePeriod: ClosedRange<Date>?, category: String? = nil, completion: ((FetchedEverything?) -> Void)?) {
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
}

