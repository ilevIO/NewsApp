//
//  NewsLoader.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation

class NewsLoader: SubscriberObject {
    var subscriptionId: Int = UUID().hashValue
    
    func checkLocalStorage() {
        //Exctract everything from core data
    }
    
    func storeLocally(articles: [ArticleDTO]) {
         //core data save object
    }
    
    func loadNext(query: String? = nil, currentLoaded: Int, for timePeriod: ClosedRange<Date>, category: String? = nil, completion: ((FetchedEverything?) -> Void)?) {
        if currentLoaded == 0 {
            checkLocalStorage()
        }
        Current.news.getEverything(.init(q: category, qInTitle: query, from: timePeriod.lowerBound, to: timePeriod.upperBound, sortBy: .publishedAt)) { news in
            if let news = news {
                
            }
            completion?(news)
        }.flatMap({ Current.api.subscriptions.registerTask($0, for: self) })
    }
}

