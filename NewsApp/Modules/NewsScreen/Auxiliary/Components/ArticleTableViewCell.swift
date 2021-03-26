//
//  ArticleTableViewCell.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import Foundation
import UIKit

class LabelWrapper: UIView {
    var label = UILabel()
    
    var text: String? {
        get {
            label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var numberOfLines: Int {
        get {
            label.numberOfLines
        }
        set {
            label.numberOfLines = newValue
        }
    }
    
    func setup() {
        self.fill(with: label)
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LabelStyle {
    var font: UIFont
    var textColor: UIColor = .black
}

extension LabelStyle {
    static let articleTitle: LabelStyle = .init(font: .systemFont(ofSize: 18, weight: .bold))
    static let articleDescription: LabelStyle = .init(
        font: .systemFont(ofSize: 12),
        textColor: .darkGray
    )
}

extension UILabel {
    func applyStyle(_ style: LabelStyle) {
        self.font = style.font
        self.textColor = style.textColor
    }
}

class ArticleTableViewCell: UITableViewCell {
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
