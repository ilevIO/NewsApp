//
//  CategoriesStackView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import UIKit

class CategoriesStackView: UIStackView {
    private let colors: [UIColor] = [
        .systemTeal,
        .systemYellow,
        .systemPink,
        .systemBlue,
        .systemRed,
        .systemGreen,
        .systemGray,
        .systemOrange,
        .systemPurple,
        .red,
        .cyan,
        .orange
    ]
    
    var onCategoryChanged: ((String) -> Void)?
    
    private var categoryViews: [CategoryView] {
        arrangedSubviews.compactMap({ $0 as? CategoryView })
    }
    
    private func categoryTapped(categoryView: CategoryView) {
        onCategoryChanged?(categoryView.title)
    }
    
    
    func select(categoryView: CategoryView) {
        categoryViews
            .filter { $0 !== categoryView }
            .forEach { $0.deselect() }
        categoryView.select()
    }
    
    func selectCategory(_ category: String) {
        categoryViews
            .first { $0.title == category }
            .flatMap { select(categoryView: $0) }
    }
    
    func configure(with categories: [String]) {
        self.removeAllArrangedSubviews()
        
        categories
            .enumerated()
            .forEach {
                let categoryView = CategoryView(
                    title: $0.element,
                    activeColor: colors[$0.offset % colors.count],
                    onTapAction: { [weak self] categoryView in
                        self?.categoryTapped(categoryView: categoryView)
                    }
                )
                self.addArrangedSubview(categoryView)
            }
    }
    
    private func setup() {
        self.distribution = .fillProportionally
        self.axis = .horizontal
    }
    
    override init(frame: CGRect = .init()) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
