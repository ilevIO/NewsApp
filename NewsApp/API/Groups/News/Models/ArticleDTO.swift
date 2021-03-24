//
//  Article.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public struct ArticleDTO: Codable {
    public var source: NewsSource?
    public var author: String?
    public var title: String?
    public var description: String?
    public var url: String?
    public var urlToImage: String?
    public var publishedAt: String?
    public var content: String
}
