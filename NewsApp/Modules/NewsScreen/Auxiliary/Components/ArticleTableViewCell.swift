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
    var textColor: UIColor = .label
}

extension LabelStyle {
    static let articleTitle: LabelStyle = .init(font: .systemFont(ofSize: 18, weight: .black))
    static let articleDescription: LabelStyle = .init(
        font: .systemFont(ofSize: 12),
        textColor: .gray
    )
    static let articleTime: LabelStyle = .init(
        font: .systemFont(ofSize: 12, weight: .light),
        textColor: .systemGray4
    )
    static let expandButton: LabelStyle = .init(
        font: .systemFont(ofSize: 14, weight: .semibold),
        textColor: .systemBlue
    )
}

extension UILabel {
    func applyStyle(_ style: LabelStyle) {
        self.font = style.font
        self.textColor = style.textColor
    }
}
