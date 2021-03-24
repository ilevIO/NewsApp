//
//  AnyCoordinator.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

class AnyCoordinator: NSObject, CoordinatorProtocol {
    weak var parent: CoordinatorProtocol?
    private(set) var presenter: SomePresenter
    
    func start(_ completion: @escaping () -> Void) {
        //presenter.coordinator = self
    }
    
    func stop(with completion: @escaping () -> Void) {
        //presenter.coordinator = nil
    }
    
    
    init(presenter: SomePresenter) {
        self.presenter = presenter
        super.init()
    }
}
