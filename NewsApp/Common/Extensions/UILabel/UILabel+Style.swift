//
//  UILabel+Style.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import UIKit

extension UILabel {
    struct LabelStyle {
        var font: UIFont
        var textColor: UIColor = .label
    }
    
    func applyStyle(_ style: LabelStyle) {
        self.font = style.font
        self.textColor = style.textColor
    }
}

extension UILabel.LabelStyle {
    static let articleTitle: UILabel.LabelStyle = .init(font: .systemFont(ofSize: 18, weight: .black))
    
    static let articleDescription: UILabel.LabelStyle = .init(
        font: .systemFont(ofSize: 12),
        textColor: .gray
    )
    
    static let articleTime: UILabel.LabelStyle = .init(
        font: .systemFont(ofSize: 12, weight: .light),
        textColor: .systemGray4
    )
    
    static let expandButton: UILabel.LabelStyle = .init(
        font: .systemFont(ofSize: 14, weight: .semibold),
        textColor: .systemBlue
    )
}
