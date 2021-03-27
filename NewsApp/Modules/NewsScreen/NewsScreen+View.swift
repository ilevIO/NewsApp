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
        
        var topBar: NewsTopBarView!
        var searchBar = UISearchBar()
        
        //MARK: - Constraints
        var topBarTopConstraint: NSLayoutConstraint!
        
        //MARK: - Setup
        private var hashTable: [Int: String] = [:]
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
        
        private func setupTopBarView() {
            topBar = .init(
                searchControlHandlers: .init(
                    onSearchButtonTapped: nil,
                    onSearchCancelTapped: { [weak presenter] in
                        presenter?.searchQueryChanged(to: "")
                    },
                    onSearchQueryChanged: { [weak presenter] searchText in
                        presenter?.searchQueryChanged(to: searchText)
                    }
                )
            )
        }
        
        private func initializeSubviews() {
            setupMainCollectionView()
            
            setupTopBarView()
        }
        
        @objc func emptyAreaTapped(_ recognizer: UITapGestureRecognizer) {
            view.endEditing(true)
        }
        
        @objc func refreshPulled(_ sender: UIRefreshControl) {
            withTagToSection(tag: sender.tag) { section in
                presenter.refresh(for: section)
            }
        }
        
        private func buildHierarchy() {
            view.addSubview(mainCollectionView)
            view.addSubview(topBar)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            //newsTableView.beginUpdates()
            //newsTableView.endUpdates()
            //newsCollectionView.contentInset.left = 16
            //newsCollectionView.contentInset.right = 16
        }
        var _viewDidAppear = false
        
        func sectionCreated(_ newSection: String) {
            hashTable[newSection.hash] = newSection
        }
        
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
        
        func withTagToSection(tag: Int, action: ((String) -> Void)) {
            guard let section = hashTable[tag] else { return }
            action(section)
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
                self.mainCollectionView.collectionViewLayout.invalidateLayout()
                self.mainCollectionView.layoutIfNeeded()
                //self.newsCollectionView.collectionViewLayout = layout
                
                //self.newsCollectionView.collectionViewLayout.invalidateLayout()
                
            }, completion: { context in
                
                self.sectionsCollectionViews.values.forEach {
                    collectionView in
                    guard let collectionView = collectionView.value else { return }
                    UIView.transition(with: collectionView, duration: 0.2, options: .transitionCrossDissolve) {
                        collectionView.collectionViewLayout.invalidateLayout()
                        
                        collectionView.visibleCells.forEach {
                            $0.isBeingPresented()
                        }
                    }
                }
                    /*self.newsCollectionView.visibleCells.forEach {
                        $0.isBeingPresented()
                    }*/
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
        
        //Fixing on current section collectionview, preventing from scrolling to other
        var section = section
        if section.isEmpty {
            mainCollectionView.scrollToItem(at: .init(item: 0, section: 0), at: .left, animated: false)
            section = sections[0]
        } else {
            mainCollectionView.isScrollEnabled = true
        }
        
        //Preventing update when articles not changed
        if let currentNews = self.newsSections[section]?.articles,
           currentNews.count == news.count &&
            currentNews
            .allSatisfy({ currentArticle in
                news.contains { $0.model == currentArticle.model }
            })
        {
            return
        }
        
        self.newsSections[section] = .init(name: section, articles: news) //= presenter.news
        
        guard let newsCollectionView = self.sectionsCollectionViews[section]?.value else { return }
        DispatchQueue.main.async {
            //newsCollectionView.insertItems(at: (currentNumber..<currentNumber + toInsert).map({ IndexPath(item: $0, section: 0) }))
            newsCollectionView.refreshControl?.endRefreshing()
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
        return
        if !forced {
            guard let newsCollectionView = self.sectionsCollectionViews[section]?.value else { return }
            newsCollectionView.refreshControl?.endRefreshing()
            let currentNumber = newsCollectionView.numberOfItems(inSection: 0)
            let toInsert = news.count - currentNumber
            guard toInsert > 0 else {
                if newsCollectionView.numberOfItems(inSection: 0) == 0 {
                    //newsCollectionView.backgroundColor = .systemRed
                } else {
                    //newsCollectionView.backgroundColor = .clear
                }
                return
            }
            //UIView.animate(withDuration: 0.3) {
            //newsTableView.beginUpdates()
            
            
        } else {
            guard let newsCollectionView = self.sectionsCollectionViews[section]?.value else { return }
            
            DispatchQueue.main.async {
                newsCollectionView.refreshControl?.endRefreshing()
            }
            newsCollectionView.reloadData()
              
        }
    }
}


extension NewsScreen.View: UIScrollViewDelegate {
    
}
