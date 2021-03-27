//
//  NewsScreen+View+UICollectionViewDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation
import UIKit

extension NewsScreen.View: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        withTagToSection(tag: collectionView.tag, action: presenter.scrollDidReachBounds)
        
        //presenter.loadNext(category: hashTable[collectionView.tag]!)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === mainCollectionView {
            return sections.count
        }
        
        var articleCount = 0
        
        withTagToSection(tag: collectionView.tag) { section in
            articleCount = newsSections[section]?.articles.count ?? 0
        }
        
        return articleCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === mainCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath)
            cell.contentView.subviews.forEach({ $0.removeAllConstraints(); $0.removeFromSuperview() })
            cell.contentView.fill(with: createCollectionView(for: sections[indexPath.row]))
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! HorizontalArticleCollectionViewCell
        withTagToSection(tag: collectionView.tag) { section in
            if let news = newsSections[section]?.articles {
                cell.configure(with: news[indexPath.row])
            }
        }
        
        cell.articleView.toggleExpanded = { [weak collectionView] in
            guard let collectionView = collectionView else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                    collectionView.collectionViewLayout.invalidateLayout()
                    collectionView.layoutIfNeeded()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        withTagToSection(tag: collectionView.tag) { section in
            presenter.newsCellTapped(at: indexPath, in: section)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView !== mainCollectionView else { return }
        DispatchQueue.main.async {
            //collectionView.collectionViewLayout.invalidateLayout()
            cell.isBeingPresented()
        }
    }
    
}

extension NewsScreen.View {
    func inferNewsCollectionViewLayout(with size: CGSize) -> UICollectionViewLayout {
        let numberOfItemsInRow = size.height > size.width ? 1 : 2
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(200)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: numberOfItemsInRow)
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: view.safeAreaInsets.bottom + 8, trailing: 16)
        section.interGroupSpacing = 18
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func createCollectionView(for newsSection: String) -> UICollectionView {
        let layout = inferNewsCollectionViewLayout(with: view.bounds.size)
        
        var collectionView: UICollectionView
        
        if let dequeuedCollectionView = self.sectionsCollectionViews[newsSection]?.value {
            collectionView = dequeuedCollectionView
        } else {
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(HorizontalArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
            collectionView.alwaysBounceVertical = true
            
            let refresher = UIRefreshControl()
            
            refresher.tag = newsSection.hash
            refresher.addTarget(self, action: #selector(refreshPulled(_:)), for: .valueChanged)
            collectionView.refreshControl = refresher
        }
        collectionView.refreshControl?.beginRefreshing()
        
        collectionView.backgroundColor = .clear
        
        sectionsCollectionViews[newsSection] = Weak(value: collectionView)
        
        
        collectionView.tag = newsSection.hash
        sectionCreated(newsSection)
        collectionView.prefetchDataSource = self
        presenter.fetchNews(for: newsSection)
        
        return collectionView
    }
}
