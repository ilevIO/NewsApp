//
//  Root+Coordinator.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import UIKit

extension Root {
    class Coordinator: AnyCoordinator {
        let window: UIWindow
        //var rootView: UIViewController
        
        func start() {
            
        }
        
        init(window: UIWindow, presenter: Presenter) {
            self.window = window
            
            let rootPresenter = presenter//Root.Presenter()
            let rootView = Root.View(with: rootPresenter)
            super.init(presenter: rootPresenter)
            rootPresenter.coordinator = self
            window.rootViewController = rootView
        }
    }

}
