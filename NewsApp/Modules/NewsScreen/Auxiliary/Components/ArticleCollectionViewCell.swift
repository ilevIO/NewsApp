//
//  ArticleCollectionViewCell.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import UIKit

struct ArticleModel {
    var source: NewsSource?
    var author: String?
    var title: String
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
    
    init(with article: Article) {
        self.title = article.title ?? "no_title".localizedCapitalized
        self.source = article.source
        self.author = article.author
        self.description = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        let formatter = ISO8601DateFormatter()// DateFormatter()
        if let publishedAt = article.publishedAt, let date = formatter.date(from: publishedAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, YYYY"
            self.publishedAt = formatter.string(from: date)
        }
        self.content = article.content
    }
}

struct ArticleCellModel {
    var model: ArticleModel
    var isExpanded: Bool = false
}
