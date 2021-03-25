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
        private var newsCollectionView: UICollectionView!
        
        //MARK: - Setup
        
        private func initializeSubviews() {
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
        }
        
        private func buildHierarchy() {
            view.addSubview(newsCollectionView)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            //newsCollectionView.contentInset.left = 16
            //newsCollectionView.contentInset.right = 16
        }
        
        private func configureSubviews() {
            newsCollectionView.dataSource = self
            newsCollectionView.delegate = self
            newsCollectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
            newsCollectionView.backgroundColor = .clear
        }
        
        private func setupLayout() {
            newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
            newsCollectionView.attach(to: view.safeAreaLayoutGuide, left: 0, right: 0)
            newsCollectionView.attach(to: self.view, top: 0, bottom: 0)
        }
        
        private func setup() {
            initializeSubviews()
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
                self.newsCollectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
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
        newsCollectionView.reloadData()
    }
}

extension NewsScreen.View: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.newsCellTapped(at: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! ArticleCollectionViewCell
        cell.configure(with: presenter.news[indexPath.row])
        return cell
    }
    
}

extension NewsScreen.View: UIScrollViewDelegate {
    
}
