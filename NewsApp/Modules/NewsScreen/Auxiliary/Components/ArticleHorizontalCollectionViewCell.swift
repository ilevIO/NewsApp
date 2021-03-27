//
//  ArticleHorizontalCollectionViewCell.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/26/21.
//

import Foundation
import UIKit

class HorizontalArticleCollectionViewCell: UICollectionViewCell {
    
    var toggleExpanded: (() -> Void)? {
        get { articleView.toggleExpanded }
        set { articleView.toggleExpanded = newValue }
    }
    
    var articleView: ArticleCellView = .init()
    
    func configure(with articleCellModel: ArticlePresentationModel) {
        articleView.configure(with: articleCellModel)
    }
    
    //MARK: - Setup
    private func buildHierarchy() {
        contentView.addSubview(articleView)
    }
    
    private func configureSubviews() {
        contentView.backgroundColor = .systemBackground
        articleView.backgroundColor = .systemBackground
        articleView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.layer.cornerRadius = 12
    }
    
    private func setupLayout() {
        let verticalMargin: CGFloat = 8
        let horizontalMargin: CGFloat = 8
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
