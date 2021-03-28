//
//  CategoryView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import UIKit

class CategoryView: UIView {
    var inactiveColor: UIColor
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
    
    private func buildHierarchy() {
        addSubview(titleLabel)
    }
    
    private func configureSubviews() {
        backgroundColor = inactiveColor
    }
    
    private func setupLayout() {
        fillLayout(with: titleLabel, insets: .init(top: 6, left: 8, bottom: 6, right: 8))
    }
    
    private func setup() {
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

