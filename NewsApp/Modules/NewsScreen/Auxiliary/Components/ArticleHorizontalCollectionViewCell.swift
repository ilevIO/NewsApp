//
//  ArticleHorizontalCollectionViewCell.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/26/21.
//

import Foundation
import UIKit

extension UIView {
    ///Notifies view with all its subviews that it is layouted
    @objc func isBeingPresented() {
        subviews.forEach { $0.isBeingPresented() }
    }
}

class HorizontalArticleCollectionViewCell: UICollectionViewCell {
    
    var toggleExpanded: (() -> Void)? {
        get { articleView.toggleExpanded }
        set { articleView.toggleExpanded = newValue }
    }
    
    var articleView: ArticleCellView = .init()
    
    func configure(with articleCellModel: ArticleCellModel) {
        articleView.configure(with: articleCellModel)
        //articleView.layoutIfNeeded()
    }
    
    private func buildHierarchy() {
        contentView.addSubview(articleView)
    }
    
    private func configureSubviews() {
        contentView.backgroundColor = .gray
        articleView.backgroundColor = .white
        articleView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setupLayout() {
        let verticalMargin: CGFloat = 8
        let horizontalMargin: CGFloat = 16
        contentView.fillLayout(with: articleView, insets: .init(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin)).forEach({ $0.priority = .required })
    }
    
    private func setup() {
        buildHierarchy()
        configureSubviews()
        setupLayout()
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
