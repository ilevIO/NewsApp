//
//  NewsScreen+UIScrollViewDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import UIKit

extension NewsScreen.View {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            if newsCollectionView.numberOfItems(inSection: 0) == presenter.news.count {
                
            }
            
            presenter.scrollDidReachBounds(withOffset: scrollView.contentOffset.y - scrollView.frame.minY)
        } else if scrollView.contentOffset.y < -160 + scrollView.contentInset.top {
            if !isReloadingData {
                isReloadingData = true
                newsCollectionView.performBatchUpdates(nil, completion: {
                    (result) in
                    self.isReloadingData = false
                })
            }
        }
    }
}
