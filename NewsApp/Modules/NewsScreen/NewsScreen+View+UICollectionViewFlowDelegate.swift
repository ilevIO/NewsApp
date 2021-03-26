//
//  NewsScreen+View+UICollectionViewFlowDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import UIKit

extension NewsScreen.View: UICollectionViewDelegateFlowLayout {
    /*func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        /*var groupOrientation: String = CatalogueImageOrientation.horizontal.rawValue
        
        if collectionView === self.allMenuCollectionView {
            groupOrientation = presenter.catalogueGroups[self.menuCollectionViews[indexPath.section].tag]?.imageOrientation?.rawValue ?? groupOrientation
        } else {
            groupOrientation = presenter.catalogueGroups[collectionView.tag]?.imageOrientation?.rawValue ?? groupOrientation
        }
        
        //View width - horizontal margin
        let width: CGFloat = self.view.frame.width - 16 * 2
        
        if groupOrientation == CatalogueImageOrientation.horizontal.rawValue {
            return .init(width: width, height: width * 0.85)
        } else {
            //TODO: remove hardcoded height
            //View width - 2 horizontal margins and 1 center inset of 16pt for 2 columns
            return .init(width: (self.view.frame.width - (16 * 2 + 16)) / 2, height: 252)
        }*/
        let horizontalMargin: CGFloat = 16 + view.safeAreaInsets.left + collectionView.contentInset.left
        return .init(width: (self.view.frame.width - (horizontalMargin) * 2 + 16) / 2, height: 252)
    }*/
    
    /*func size(collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        /*let productCell = ProductCellView()
        productCell.dynamicHeight = true
        var product: Product?
        
        if collectionView === self.allMenuCollectionView {
            if let productItem = presenter.catalogueGroups[self.menuCollectionViews[indexPath.section].tag]?.products?[indexPath.row] {
                product = Product(from: productItem, withVendorId: self.presenter.restaurant.id)
            }
        } else {
            if let productItem = presenter.catalogueGroups[collectionView.tag]?.products?[indexPath.row] {
                product = Product(from: productItem, withVendorId: self.presenter.restaurant.id)
            }
        }
        productCell.product = product
        productCell.frame.size.width = self.view.frame.width - 16 * 2
        productCell.layoutSubviews()
        productCell.setNeedsLayout()
        productCell.layoutIfNeeded()*/
        return .init(width: 120, height: 300)//productCell.frame.size
    }*/
}
