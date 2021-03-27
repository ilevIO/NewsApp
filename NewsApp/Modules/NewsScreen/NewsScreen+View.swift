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
    
    struct NewsSectionModel {
        var name: String
        var articles: [ArticleCellModel]
    }

    class View: UIViewController {
        static let topBarHeight: CGFloat = 60
        
        var usesCollectionView = true
        var presenter: Presenter!
        
        var scrollState: ScrollState = .init()
        var prevTopBarVisibleHeight: CGFloat = 0
        
        var isReloadingData = false
        //var news: [ArticleCellModel] { presenter.news }
        var newsSections: [String: NewsSectionModel] { presenter.news }
        //MARK: - Subviews
        var newsCollectionView: UICollectionView!
        var newsTableView: UITableView = .init()
        var refreshControl = UIRefreshControl()
        
        var topBar = NewsTopBarView()
        var searchBar = UISearchBar()
        
        //MARK: - Constraints
        var topBarTopConstraint: NSLayoutConstraint!
        
        let searchButton = UIButton()
        //MARK: - Setup
        var hashTable: [Int: String] = [:]
        var mainCollectionView: UICollectionView!
        
        private func setupMainCollectionView() {
            let size = NSCollectionLayoutSize(
                widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                heightDimension: NSCollectionLayoutDimension.fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitem: item, count: 1)
            group.interItemSpacing = .fixed(12)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            section.interGroupSpacing = 0
            section.orthogonalScrollingBehavior = .paging
            let layout = UICollectionViewCompositionalLayout(section: section)
            
            /*let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical*/
            //layout.estimatedItemSize = .init(width: 180, height: 600)
            //layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
            //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        }
        
        private func initializeSubviews() {
            setupMainCollectionView()
            return
            let size = NSCollectionLayoutSize(
                widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                heightDimension: NSCollectionLayoutDimension.estimated(200)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
            group.interItemSpacing = .fixed(12)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16)
            section.interGroupSpacing = 18
            let layout = UICollectionViewCompositionalLayout(section: section)
            /*let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical*/
            //layout.estimatedItemSize = .init(width: 180, height: 600)
            //layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
            //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            newsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            //newsCollectionView.contentInset.left = 16
            //newsCollectionView.contentInset.right = 16
        }
        
        @objc func emptyAreaTapped(_ recognizer: UITapGestureRecognizer) {
            view.endEditing(true)
        }
        
        @objc func refreshPulled(_ sender: UIRefreshControl) {
            presenter.refresh(for: hashTable[sender.tag]!)
        }
        
        private func buildHierarchy() {
            if usesCollectionView {
                view.addSubview(mainCollectionView)
                //mainCollectionView.addSubview(refreshControl)
                //view.addSubview(newsCollectionView)
                //newsCollectionView.addSubview(refreshControl)
            } else {
                view.addSubview(newsTableView)
                newsTableView.addSubview(refreshControl)
            }
            view.addSubview(topBar)
            //topBar.addSubview(searchBar)
            //topBar.addSubview(searchButton)
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
            topBar.backgroundColor = .systemGroupedBackground
            view.backgroundColor = .systemGroupedBackground
            topBar.dropShadow(color: .darkGray, opacity: 0.2, radius: 12)
            
            topBar.categoriesStackView.configure(with: sections)
            
            if usesCollectionView {
                /*newsCollectionView.dataSource = self
                newsCollectionView.delegate = self
                newsCollectionView.register(HorizontalArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
                newsCollectionView.backgroundColor = .clear
                newsCollectionView.alwaysBounceVertical = true*/
                
                mainCollectionView.dataSource = self
                mainCollectionView.delegate = self
                mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
                mainCollectionView.backgroundColor = .clear
                mainCollectionView.alwaysBounceVertical = true
            } else {
                newsTableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "NewsCell")
                newsTableView.separatorStyle = .none
                newsTableView.allowsSelection = true
                newsTableView.delegate = self
                newsTableView.dataSource = self
                //newsTableView.rowHeight = UITableView.automaticDimension
                newsTableView.estimatedRowHeight = 400//UITableView.automaticDimension
                newsTableView.contentInset.top = 16
                newsTableView.contentInset.bottom = 16
            }
            refreshControl.addTarget(self, action: #selector(refreshPulled(_:)), for: .valueChanged)
            
            searchBar.widthAnchor.constraint(equalToConstant: 200).isActive = true
            searchBar.barStyle = .default
            searchBar.backgroundImage = .init()
            searchBar.delegate = self
            searchBar.showsCancelButton = true
            
            searchButton.setImage(UIImage(systemName: "search"), for: .normal)
            
        }
        var isSearchExpanded = false {
            didSet {
                onSearchToggled()
            }
        }
        
        var searchBarExpandedConstraints: [NSLayoutConstraint] = []
        var searchBarCollapsedConstraints: [NSLayoutConstraint] = []
        
        func expandSearchBar() {
            NSLayoutConstraint.deactivate(searchBarCollapsedConstraints)
            NSLayoutConstraint.activate(searchBarExpandedConstraints)
        }
        
        func collapseSearchBar() {
            NSLayoutConstraint.deactivate(searchBarExpandedConstraints)
            NSLayoutConstraint.activate(searchBarCollapsedConstraints)
        }
        
        func onSearchToggled() {
            if isSearchExpanded {
                expandSearchBar()
            } else {
                collapseSearchBar()
            }
        }
        
        @objc func searchButtonTapped(_ sender: UIButton) {
            isSearchExpanded = true
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
            //searchBar.attach(to: topBar, left: horizontalMargin, bottom: verticalInset)
            
            if usesCollectionView {
                mainCollectionView.translatesAutoresizingMaskIntoConstraints = false
                mainCollectionView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
                mainCollectionView.attach(to: self.view, bottom: 0)
                mainCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0).isActive = true
                /*newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
                newsCollectionView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
                newsCollectionView.attach(to: self.view, bottom: 0)
                newsCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0).isActive = true*/
            } else {
                newsTableView.translatesAutoresizingMaskIntoConstraints = false
                newsTableView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
                newsTableView.attach(to: self.view, bottom: 0)
                newsTableView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0).isActive = true
            }
        }
        
        private func setup() {
            initializeSubviews()
            buildHierarchy()
            configureSubviews()
            setupLayout()
        }
        
        //MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setup()
        }
        
        var sections = ["Apple", "IT", "Belarus", "Cocoa", "iOS"]
        
        struct Weak<T: AnyObject> {
            weak var value: T?
        }
        
        var sectionsCollectionViews: [String: Weak<UICollectionView>] = [:]
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: { context in
                
                self.sectionsCollectionViews.values.forEach {
                    let layout = self.inferNewsCollectionViewLayout(with: size)
                    $0.value?.collectionViewLayout = layout
                    $0.value?.collectionViewLayout.invalidateLayout()
                }
                //self.newsCollectionView.collectionViewLayout = layout
                
                //self.newsCollectionView.collectionViewLayout.invalidateLayout()
                
                
            }, completion: { context in
                if self.usesCollectionView {
                    self.sectionsCollectionViews.values.forEach {
                        $0.value?.visibleCells.forEach {
                            $0.isBeingPresented()
                        }
                    }
                    /*self.newsCollectionView.visibleCells.forEach {
                        $0.isBeingPresented()
                    }*/
                } else {
                    self.newsTableView.visibleCells.forEach({ $0.layoutSubviews() })
                }
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
    func update(with news: [ArticleCellModel], for section: String, forced: Bool) {
        //self.news = news
        refreshControl.endRefreshing()
        if !forced {
            if usesCollectionView {
                guard let newsCollectionView = self.sectionsCollectionViews[section]?.value else { return }
                newsCollectionView.refreshControl?.endRefreshing()
                let currentNumber = newsCollectionView.numberOfItems(inSection: 0)
                let toInsert = news.count - currentNumber
                guard toInsert > 0 else { return }
                //UIView.animate(withDuration: 0.3) {
                //newsTableView.beginUpdates()
                
                DispatchQueue.main.async {
                    newsCollectionView.insertItems(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }))
                    newsCollectionView.collectionViewLayout.invalidateLayout()
                }
                //}
                //newsTableView.endUpdates()
            } else {
                let currentNumber = newsTableView.numberOfRows(inSection: 0)//self.newsCollectionView.numberOfItems(inSection: 0)
                let toInsert = news.count - currentNumber
                guard toInsert > 0 else { return }
                //UIView.animate(withDuration: 0.3) {
                newsTableView.beginUpdates()
                self.newsTableView.insertRows(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }), with: .fade)//newsCollectionView.insertItems(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }))
                //}
                newsTableView.endUpdates()
            }
        } else {
            //UIView.animate(withDuration: 0.3) {
            if usesCollectionView {
                guard let newsCollectionView = self.sectionsCollectionViews[section]?.value else { return }
                
                DispatchQueue.main.async {
                    newsCollectionView.refreshControl?.endRefreshing()
                }
               // DispatchQueue.main.async {
                    newsCollectionView.reloadData()
               // }
            } else {
                self.newsTableView.reloadData()
            }
        }
    }
}


extension NewsScreen.View: UIScrollViewDelegate {
    
}
