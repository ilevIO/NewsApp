//
//  Conformance.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

protocol CoordinatorProtocol: class {
    var parent: CoordinatorProtocol? { get set }
    
    func start(_ completion: @escaping () -> Void)
    func stop(with completion: @escaping () -> Void)
}

protocol HasCoordinator {
    var coordinator: CoordinatorProtocol? { get set }
}

protocol SomePresenter: HasCoordinator { }
