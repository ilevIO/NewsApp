//
//  GetNewsSortMethod.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

public enum GetNewsSortMethod: String, Codable {
    case relevancy = "relevancy"
    case publishedAt = "publishedAt"
    case popularity = "popularity"
}
