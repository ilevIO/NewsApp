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
        //MARK: - Consts
        static let topBarHeight: CGFloat = 40
        
        var presenter: Presenter!
        
        //MARK: - State
        private(set)var _viewDidAppear = false
        var scrollState: ScrollState = .init()
        var prevTopBarVisibleHeight: CGFloat = 0
        
        var newsSections: [String: NewsSectionModel] = [:]
        
        private var hashTable: [Int: String] = [:]
        var sections: [String] { presenter.sections }
        
        //MARK: - Subviews
        var mainCollectionView: UICollectionView!
        ///CollectionViews with articles related to their categories
        var sectionsCollectionViews: [String: Weak<UICollectionView>] = [:]
        
        var topBar: NewsTopBarView!
        var searchBar = UISearchBar()
        
        //MARK: - Constraints
        var topBarTopConstraint: NSLayoutConstraint!
        
        //MARK: - Handlers
        @objc func emptyAreaTapped(_ recognizer: UITapGestureRecognizer) {
            view.endEditing(true)
        }
        
        @objc func refreshPulled(_ sender: UIRefreshControl) {
            withTagToSection(tag: sender.tag) { section in
                if !presenter.refresh(for: section) {
                    sender.endRefreshing()
                }
            }
        }
        
        func sectionCreated(_ newSection: String) {
            hashTable[newSection.hash] = newSection
        }
        
        ///Performs action with category name infering from its hash if found
        func withTagToSection(tag: Int, action: ((String) -> Void)) {
            guard let section = hashTable[tag] else { return }
            action(section)
        }
        
        //MARK: - Setup
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
        
        private func buildHierarchy() {
            view.addSubview(mainCollectionView)
            view.addSubview(topBar)
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
        }
        
        private func setupLayout() {
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
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            _viewDidAppear = false
            
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.isHidden = true
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            _viewDidAppear = true
        }
        
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

extension NewsScreen.View: NewsScreenView {
    func update(with news: [ArticlePresentationModel], for category: String?) {
        var updatedCategory: String
        //Load search results in the first collectionView data
        if let category = category {
            updatedCategory = category
        } else {
            //Performing search as the first category
            mainCollectionView.scrollToItem(at: .init(item: 0, section: 0), at: .left, animated: false)
            updatedCategory = sections[0]
        }
        
        guard let newsCollectionView = self.sectionsCollectionViews[updatedCategory]?.value else { return }
        
        newsCollectionView.refreshControl?.endRefreshing()
        
        //Preventing update when articles not changed
        if let currentNews = self.newsSections[updatedCategory]?.articles,
           currentNews.count == news.count &&
            currentNews.allSatisfy({ currentArticle in
                news.contains { $0.model == currentArticle.model }
            }) { return }
        
        newsSections[updatedCategory] = .init(name: updatedCategory, articles: news)
        
        DispatchQueue.main.async {
            UIView.transition(with: newsCollectionView, duration: 0.2, options: .transitionCrossDissolve) {
                newsCollectionView.reloadData()
                newsCollectionView.collectionViewLayout.invalidateLayout()
                newsCollectionView.layoutIfNeeded()
            }
        }
    }
}
