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
        static let topBarHeight: CGFloat = 56
        var presenter: Presenter!
        
        var scrollState: ScrollState = .init()
        var prevTopBarVisibleHeight: CGFloat = 0
        
        var isReloadingData = false
        var news: [ArticleCellModel] { presenter.news }
        //MARK: - Subviews
        //var newsCollectionView: UICollectionView!
        var newsTableView: UITableView = .init()
        var refreshControl = UIRefreshControl()
        
        var topBar = UIView()
        var searchBar = UISearchBar()
        
        //MARK: - Constraints
        var topBarTopConstraint: NSLayoutConstraint!
        
        //MARK: - Setup
        
        /*private func initializeSubviews() {
            let size = NSCollectionLayoutSize(
                widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                heightDimension: NSCollectionLayoutDimension.estimated(200)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 2)
            group.interItemSpacing = .fixed(12)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            section.interGroupSpacing = 8
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            /*let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical*/
            //layout.estimatedItemSize = .init(width: 180, height: 600)
            //layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
            //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            newsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            //newsCollectionView.contentInset.left = 16
            //newsCollectionView.contentInset.right = 16
        }*/
        
        @objc func refreshPulled(_ sender: UIRefreshControl) {
            presenter.refresh()
        }
        
        private func buildHierarchy() {
            /*view.addSubview(newsCollectionView)
            newsCollectionView.addSubview(refreshControl)*/
            view.addSubview(newsTableView)
            newsTableView.addSubview(refreshControl)
            view.addSubview(topBar)
            topBar.addSubview(searchBar)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            //newsTableView.beginUpdates()
            //newsTableView.endUpdates()
            //newsCollectionView.contentInset.left = 16
            //newsCollectionView.contentInset.right = 16
        }
        var _viewDidAppear = false
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            _viewDidAppear = false
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            _viewDidAppear = true
        }
        
        private func configureSubviews() {
            topBar.backgroundColor = .systemBackground
            /*newsCollectionView.dataSource = self
            newsCollectionView.delegate = self
            newsCollectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
            newsCollectionView.backgroundColor = .clear
            newsCollectionView.alwaysBounceVertical = true*/
            newsTableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "NewsCell")
            newsTableView.separatorStyle = .none
            newsTableView.allowsSelection = true
            newsTableView.delegate = self
            newsTableView.dataSource = self
            //newsTableView.rowHeight = UITableView.automaticDimension
            newsTableView.estimatedRowHeight = 400//UITableView.automaticDimension
            newsTableView.contentInset.top = 16
            newsTableView.contentInset.bottom = 16
            
            refreshControl.addTarget(self, action: #selector(refreshPulled(_:)), for: .valueChanged)
            
            searchBar.widthAnchor.constraint(equalToConstant: 200).isActive = true
            searchBar.barStyle = .default
            searchBar.backgroundImage = .init()
            searchBar.delegate = self
        }
        
        private func setupLayout() {
            let horizontalMargin: CGFloat = 8
            let verticalInset: CGFloat = 8
            
            topBar.translatesAutoresizingMaskIntoConstraints = false
            topBar.attach(to: self.view, left: 0, right: 0)
            topBarTopConstraint = topBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Self.topBarHeight)
            topBarTopConstraint.isActive = true
            topBar.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor).isActive = true
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            searchBar.attach(to: topBar, left: horizontalMargin, bottom: verticalInset)
            
            /*newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
            newsCollectionView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
            newsCollectionView.attach(to: self.view, top: 0, bottom: 0)*/
            
            newsTableView.translatesAutoresizingMaskIntoConstraints = false
            newsTableView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
            newsTableView.attach(to: self.view, bottom: 0)
            newsTableView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0).isActive = true
        }
        
        private func setup() {
            //initializeSubviews()
            buildHierarchy()
            configureSubviews()
            setupLayout()
            self.view.backgroundColor = .systemRed
        }
        
        //MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setup()
            
            presenter.fetchNews()
            self.view.backgroundColor = .white
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: { context in
                //self.newsTableView.layoutIfNeeded()
                //self.newsCollectionView.collectionViewLayout.invalidateLayout()
            }, completion: { context in
                self.newsTableView.visibleCells.forEach({ $0.layoutSubviews() })
            })
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
    func update(with news: [ArticleCellModel], forced: Bool) {
        //self.news = news
        refreshControl.endRefreshing()
        if !forced {
            let currentNumber = newsTableView.numberOfRows(inSection: 0)//self.newsCollectionView.numberOfItems(inSection: 0)
            let toInsert = news.count - currentNumber
            guard toInsert > 0 else { return }
            //UIView.animate(withDuration: 0.3) {
            newsTableView.beginUpdates()
            self.newsTableView.insertRows(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }), with: .fade)//newsCollectionView.insertItems(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }))
            //}
            newsTableView.endUpdates()
        } else {
            //UIView.animate(withDuration: 0.3) {
                self.newsTableView.reloadData()
            //}
            //self.newsCollectionView.reloadData()
        }
    }
}

extension NewsScreen.View: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! ArticleCollectionViewCell
        cell.configure(with: news[indexPath.row])
        return cell
    }
    
    
}

extension NewsScreen.View: UIScrollViewDelegate {
    
}
