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
        var newsSections: [String: NewsSectionModel] = [:]
        //MARK: - Subviews
        var newsCollectionView: UICollectionView!
        var newsTableView: UITableView = .init()
        var refreshControl = UIRefreshControl()
        
        var topBar = NewsTopBarView()
        var searchBar = UISearchBar()
        
        //MARK: - Constraints
        var topBarTopConstraint: NSLayoutConstraint!
        
        //MARK: - Setup
        var hashTable: [Int: String] = [:]
        var mainCollectionView: UICollectionView!
        var sections: [String] { presenter.sections }
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
            
            section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, offset, env) in
                guard let self = self else { return }
                let index = Int(round(offset.x /  self.mainCollectionView.frame.width))
                let section = self.sections[index]
                UIView.animate(withDuration: 0.2) {
                    self.topBar.categoriesStackView.selectCategory(section)
                }
            }
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            
            mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        }
        
        private func initializeSubviews() {
            setupMainCollectionView()
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
            topBar.categoriesStackView.onCategoryChanged = { [weak self] category in
                guard let categoryIndex = self?.sections.firstIndex(of: category) else { return }
                self?.mainCollectionView.scrollToItem(at: .init(item: categoryIndex, section: 0), at: .left, animated: true)
            }
            
            mainCollectionView.dataSource = self
            mainCollectionView.delegate = self
            mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
            mainCollectionView.backgroundColor = .clear
            mainCollectionView.alwaysBounceHorizontal = true
            
            searchBar.widthAnchor.constraint(equalToConstant: 200).isActive = true
            searchBar.barStyle = .default
            searchBar.backgroundImage = .init()
            searchBar.delegate = self
            searchBar.showsCancelButton = true
            
            //searchButton.setImage(UIImage(systemName: "search"), for: .normal)
            
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
            
            mainCollectionView.translatesAutoresizingMaskIntoConstraints = false
            mainCollectionView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
            mainCollectionView.attach(to: self.view, bottom: 0)
            mainCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0).isActive = true
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
                    $0.value?.layoutIfNeeded()
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
        self.newsSections[section] = .init(name: section, articles: news) //= presenter.news
        refreshControl.endRefreshing()
        if !forced {
            if usesCollectionView {
                guard let newsCollectionView = self.sectionsCollectionViews[section]?.value else { return }
                newsCollectionView.refreshControl?.endRefreshing()
                let currentNumber = newsCollectionView.numberOfItems(inSection: 0)
                let toInsert = news.count - currentNumber
                guard toInsert > 0 else {
                    if newsCollectionView.numberOfItems(inSection: 0) == 0 {
                        newsCollectionView.backgroundColor = .systemRed
                    } else {
                        newsCollectionView.backgroundColor = .clear
                    }
                    return
                }
                //UIView.animate(withDuration: 0.3) {
                //newsTableView.beginUpdates()
                
                DispatchQueue.main.async {
                    //newsCollectionView.insertItems(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }))
                    UIView.transition(with: newsCollectionView, duration: 0.2, options: .transitionCrossDissolve) {
                        newsCollectionView.reloadData()
                        newsCollectionView.collectionViewLayout.invalidateLayout()
                        newsCollectionView.layoutIfNeeded()
                    }
                        
                    //newsCollectionView.setNeedsLayout()
                    //DispatchQueue.main.async {
                        /*UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                            newsCollectionView.collectionViewLayout.invalidateLayout()
                            newsCollectionView.layoutIfNeeded()
                        }*/
                    //}
                    /*newsCollectionView.collectionViewLayout.invalidateLayout()
                    newsCollectionView.layoutIfNeeded()*/
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
