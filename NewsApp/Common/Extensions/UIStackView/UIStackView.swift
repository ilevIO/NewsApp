//
//  UIStackView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import Foundation
import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        for view in removedSubviews {
            view.removeAllConstraints()
            NSLayoutConstraint.deactivate(view.constraints)
            view.removeFromSuperview()
        }
    }
}
