//
//  Root+View.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import UIKit

extension Root {
    class View: UINavigationController, RootView {
        
        var presenter: Presenter!
        
        func setup() {
            self.viewControllers = [presenter.rootView]
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            viewControllers = [presenter.rootView]
            navigationBar.isHidden = true
        }
        
        init(with presenter: Presenter) {
            self.presenter = presenter
            super.init(nibName: nil, bundle: nil)
            presenter.view = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
