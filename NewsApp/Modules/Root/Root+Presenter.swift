//
//  Root+Presenter.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import UIKit

extension Root {
    class Presenter {
        weak var view: RootView?
        
        var rootView = NewsScreen.view(with: .init())
        
        func navigate(to viewController: UIViewController) {
            rootView.navigationController?.pushViewController(viewController, animated: true)
        }
        
        init() {
            
        }
    }
}
