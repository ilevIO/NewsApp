//
//  NewsScreen+View.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import UIKit

extension NewsScreen {
    
    static func view(with presenter: Presenter) -> UIViewController {
        View(with: presenter)
    }
    
    class View: UIViewController, NewsScreenView {
        var presenter: Presenter!
        
        //MARK: - Subviews
        private let newsTableView: UITableView = .init()
        
        //MARK: - Setup
        private func buildHierarchy() {
            
        }
        
        private func configureSubviews() {
            
        }
        
        private func setupLayout() {
            
        }
        
        private func setup() {
            buildHierarchy()
            configureSubviews()
            setupLayout()
            
            self.view.backgroundColor = .systemRed
        }
        
        //MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setup()
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

extension NewsScreen.View: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        .init()
    }
    
    
}

extension NewsScreen.View: UIScrollViewDelegate {
    
}
