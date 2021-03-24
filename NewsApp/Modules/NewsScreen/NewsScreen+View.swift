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
    
    class View: UIViewController {
        var presenter: Presenter!
        
        //MARK: - Subviews
        private let newsTableView: UITableView = .init()
        
        //MARK: - Setup
        private func buildHierarchy() {
            view.addSubview(newsTableView)
        }
        
        private func configureSubviews() {
            newsTableView.dataSource = self
            newsTableView.delegate = self
            newsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewsCell")
        }
        
        private func setupLayout() {
            view.fillLayout(with: newsTableView)
        }
        
        private func setup() {
            buildHierarchy()
            configureSubviews()
            setupLayout()
        }
        
        //MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setup()
            
            presenter.fetchNews()
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

extension NewsScreen.View: NewsScreenView {
    func update() {
        newsTableView.reloadData()
    }
}

extension NewsScreen.View: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        cell.textLabel?.text = presenter.news[indexPath.row].title
        return cell
    }
    
    
}

extension NewsScreen.View: UIScrollViewDelegate {
    
}
