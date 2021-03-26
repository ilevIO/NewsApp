//
//  ArticlesHorizontalList.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import Foundation
import UIKit

struct CategoryArticles {
    var category: String
    var articles: [ArticleModel]
}

class SimpleArticleCollectionViewCell: UICollectionViewCell {
    
}

class ArticlesHorizontalListView: UIView {
    //MARK: - Subviews
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 160, height: 300)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    //var scrollView = UIScrollView()
    //var stackView = UIStackView()
    var categoryTitleLabel = UILabel()
    
    var category: String?
    var categoryArticles: CategoryArticles?
    
    func configure(with categoryArticles: CategoryArticles) {
        self.categoryArticles = categoryArticles
        //stackView.removeAllArrangedSubviews()
        
    }
    
    private func buildHierarchy() {
        addSubview(categoryTitleLabel)
        addSubview(collectionView)
        //addSubview(scrollView)
        //addSubview(stackView)
    }
    
    private func configureSubviews() {
        //stackView.axis = .horizontal
    }
    
    private func setupLayout() {
        let verticalMargin: CGFloat = 4
        let verticalInset: CGFloat = 4
        let horizontalMargin: CGFloat = 12
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryTitleLabel.attach(to: self, left: horizontalMargin, top: verticalMargin)
        categoryTitleLabel.setContentHuggingPriority(.required, for: .vertical)
        /*
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: verticalInset).isActive = true
        scrollView.attach(to: self, left: 0, right: 0, bottom: 0)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.attach(to: scrollView, left: 0, right: 0)
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true*/
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
