//
//  Root+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

extension Root {
    class Presenter: SomePresenter {
        
        var coordinator: CoordinatorProtocol?
        
        weak var view: RootView?
        
        var rootView = NewsScreen.view(with: .init())
        
        init() {
            
        }
    }
}
