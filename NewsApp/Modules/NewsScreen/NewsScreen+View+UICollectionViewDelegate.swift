//
//  NewsScreen+View+UICollectionViewDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation
import UIKit

extension NewsScreen.View: UICollectionViewDelegate, UICollectionViewDataSource {
    func createCollectionView() -> UICollectionView {
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HorizontalArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsCell")
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        newsCollectionView = collectionView
        return collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === mainCollectionView {
            return 5
        }
        return news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === mainCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath)
            cell.contentView.subviews.forEach({ $0.removeAllConstraints(); $0.removeFromSuperview() })
            cell.contentView.fill(with: createCollectionView())
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! HorizontalArticleCollectionViewCell
        cell.configure(with: news[indexPath.row])
        cell.articleView.toggleExpanded = { [weak collectionView] in
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.newsCellTapped(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView !== mainCollectionView else { return }
        DispatchQueue.main.async {
            //collectionView.collectionViewLayout.invalidateLayout()
            cell.isBeingPresented()
        }
    }
    
}
