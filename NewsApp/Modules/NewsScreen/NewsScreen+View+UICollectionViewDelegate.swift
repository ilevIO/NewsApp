//
//  NewsScreen+View+UICollectionViewDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation
import UIKit

extension NewsScreen.View: UICollectionViewDelegate, UICollectionViewDataSource {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 18
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func createCollectionView(for newsSection: String) -> UICollectionView {
        let layout = inferNewsCollectionViewLayout(with: view.bounds.size)
        /*let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical*/
        //layout.estimatedItemSize = .init(width: 180, height: 600)
        //layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HorizontalArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        self.sectionsCollectionViews[newsSection] = Weak(value: collectionView)
        //newsCollectionView = collectionView
        let refresher = UIRefreshControl()
        refresher.tag = newsSection.hash
        collectionView.addSubview(refresher)
        collectionView.tag = newsSection.hash
        hashTable[newsSection.hash] = newsSection
        return collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === mainCollectionView {
            return sections.count
        }
        return newsSections[hashTable[collectionView.tag]!]?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === mainCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath)
            cell.contentView.subviews.forEach({ $0.removeAllConstraints(); $0.removeFromSuperview() })
            cell.contentView.fill(with: createCollectionView(for: sections[indexPath.row]))
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! HorizontalArticleCollectionViewCell
        let news = newsSections[hashTable[collectionView.tag]!]?.articles ?? []
        cell.configure(with: news[indexPath.row])
        cell.articleView.toggleExpanded = { [weak collectionView] in
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.newsCellTapped(at: indexPath, in: hashTable[collectionView.tag]!)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView !== mainCollectionView else { return }
        DispatchQueue.main.async {
            //collectionView.collectionViewLayout.invalidateLayout()
            cell.isBeingPresented()
        }
    }
    
}
