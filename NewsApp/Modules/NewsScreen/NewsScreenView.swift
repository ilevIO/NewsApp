//
//  NewsScreenView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

protocol NewsScreenView: class {
    func update(with news: [ArticlePresentationModel], for category: String?)
}
