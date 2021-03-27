//
//  TopBar.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation
import UIKit

class CategoryView: UIView {
    var inactiveColor: UIColor = .lightGray
    var activeColor: UIColor
    var title: String {
        get {
            titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }
    var onTapAction: ((CategoryView) -> Void)? = nil
    
    //MARK: - Subviews
    var titleLabel: UILabel = .init()
    
    
    @objc func didTap(_ recognizer: UITapGestureRecognizer) {
        onTapAction?(self)
    }
    
    func select() {
        backgroundColor = activeColor
    }
    
    func deselect() {
        backgroundColor = inactiveColor
    }
    
    func buildHierarchy() {
        addSubview(titleLabel)
    }
    
    func configureSubviews() {
        backgroundColor = inactiveColor
    }
    
    func setupLayout() {
        fillLayout(with: titleLabel, insets: .init(top: 6, left: 8, bottom: 6, right: 8))
    }
    
    func setup() {
        buildHierarchy()
        configureSubviews()
        setupLayout()
        
        backgroundColor = inactiveColor
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }
    
    init(title: String, activeColor: UIColor, inactiveColor: UIColor = .systemGray4, onTapAction: ((CategoryView) -> Void)?, frame: CGRect = .zero) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.onTapAction = onTapAction
        super.init(frame: frame)
        
        setup()
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CategoriesStackView: UIStackView {
    let colors: [UIColor] = [
        .systemTeal,
        .systemRed,
        .systemPink,
        .systemBlue,
        .systemGray,
        .systemGreen,
        .systemOrange,
        .systemYellow,
        .systemPurple,
        .red,
        .cyan,
        .orange
    ]
    
    //var stackView: UIStackView = .init()
    
    var onCategoryChanged: ((String) -> Void)?
    
    var categoryViews: [CategoryView] {
        arrangedSubviews.compactMap({ $0 as? CategoryView })
    }
    
    func select(categoryView: CategoryView) {
        categoryViews
            .filter { $0 !== categoryView }
            .forEach { $0.deselect() }
        categoryView.select()
    }
    
    private func categoryTapped(categoryView: CategoryView) {
        onCategoryChanged?(categoryView.title)
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
                ) /*UIView()
                let color = colors[$0.offset % colors.count]
                categoryView.backgroundColor = color
                let titleLabel = UILabel()
                titleLabel.text = $0.element
                categoryView.fill(with: titleLabel, insets: .init(top: 4, left: 8, bottom: 4, right: 8))*/
                self.addArrangedSubview(categoryView)
            }
    }
    
    private func buildHierarhy() {
        //addSubview(stackView)
    }
    
    private func configureSubviews() {
        self.distribution = .fillProportionally
        self.axis = .horizontal
    }
    
    private func setupLayout() {
        //fillLayout(with: stackView)
    }
    
    private func setup() {
        buildHierarhy()
        configureSubviews()
        setupLayout()
    }
    
    override init(frame: CGRect = .init()) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NewsTopBarView: UIView {
    //MARK: - Subviews
    var categoriesStackView: CategoriesStackView = .init()
    var categoriesScrollView: UIScrollView = .init()
    var searchButton: UIButton = .init()
    var searchView: UIView = .init()
    var searchBar: UISearchBar = .init()
    
    var onSearchButtonTapped: (() -> Void)? = nil
    
    var contentView: UIView = .init()
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        onSearchButtonTapped?()
    }
    
    private func buildHierarhy() {
        addSubview(contentView)
        contentView.addSubview(categoriesScrollView)
        categoriesScrollView.addSubview(categoriesStackView)
        contentView.addSubview(searchButton)
    }
    
    private func configureSubviews() {
        categoriesStackView.axis = .horizontal
        categoriesStackView.alignment = .bottom
        categoriesScrollView.showsHorizontalScrollIndicator = false
        
        searchButton.setImage(.add, for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupLayout() {
        fillLayout(with: contentView)
        
        categoriesScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoriesScrollView.attach(to: contentView, left: 0, top: 0, bottom: 0)
        
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.attach(to: categoriesScrollView, left: 0, right: 0)
        categoriesStackView.attach(to: contentView, top: 0, bottom: 0)
        
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.attach(to: contentView, right: 0, bottom: 0)
        categoriesScrollView.rightAnchor.constraint(equalTo: searchButton.leftAnchor, constant: 0).isActive = true
    }
    
    private func setup() {
        buildHierarhy()
        configureSubviews()
        setupLayout()
    }
    
    override init(frame: CGRect = .init()) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
