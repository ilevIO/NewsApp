//
//  TopBar.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation
import UIKit

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
    
    func configure(with categories: [String]) {
        self.removeAllArrangedSubviews()
        
        categories
            .enumerated()
            .forEach {
                let categoryView = UIView()
                let color = colors[$0.offset % colors.count]
                categoryView.backgroundColor = color
                let titleLabel = UILabel()
                titleLabel.text = $0.element
                categoryView.fill(with: titleLabel, insets: .init(top: 4, left: 8, bottom: 4, right: 8))
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
    
    private func buildHierarhy() {
        addSubview(categoriesScrollView)
        categoriesScrollView.addSubview(categoriesStackView)
    }
    
    private func configureSubviews() {
        categoriesStackView.axis = .horizontal
        categoriesStackView.alignment = .bottom
        categoriesScrollView.showsHorizontalScrollIndicator = false
    }
    
    private func setupLayout() {
        fillLayout(with: categoriesScrollView)
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.attach(to: categoriesScrollView, left: 0, right: 0)
        categoriesStackView.attach(to: self, top: 0, bottom: 0)
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
