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
        
        var news: [String] = []
        
        func fetchNews() {
            
        }
    }
}
