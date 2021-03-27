//
//  UIView+Presentation.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import UIKit

extension UIView {
    ///Notifies view with all its subviews that it is layouted
    @objc func isBeingPresented() {
        subviews.forEach { $0.isBeingPresented() }
    }
}
