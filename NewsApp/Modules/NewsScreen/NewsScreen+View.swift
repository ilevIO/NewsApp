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
            /*let size = NSCollectionLayoutSize(
                        widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                        heightDimension: NSCollectionLayoutDimension.estimated(200)
                    )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 2)
            group.interItemSpacing = .fixed(12)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 10
            
            let layout = UICollectionViewCompositionalLayout(section: section)*/
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
            //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            newsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        }
        
        private func buildHierarchy() {
            view.addSubview(newsCollectionView)
        }
        
        private func configureSubviews() {
            newsCollectionView.dataSource = self
            newsCollectionView.delegate = self
            newsCollectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
            newsCollectionView.backgroundColor = .clear
        }
        
        private func setupLayout() {
            view.fillLayout(with: newsCollectionView)
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
