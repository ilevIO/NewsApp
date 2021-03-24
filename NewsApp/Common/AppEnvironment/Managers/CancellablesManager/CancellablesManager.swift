//
//  CancellablesManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

public protocol SubscriberObject: AnyObject {
    var subscriptionId: Int { get }
}

public protocol CancellableHashable: Hashable {
    func cancel()
}

public class CancellablesManager<T: CancellableHashable> {
    private let lock = NSLock()
    public typealias CancelType = T
    public typealias Storage = Set<CancelType>

    class SubscriberTasks {
        var subscriptionId: Int?
        var tasks: Set<CancelType> = .init()
        
        func addTask(_ task: CancelType) {
            tasks.insert(task)
        }
        
        func removeTask(_ task: CancelType) {
            tasks.remove(task)
        }
        
        func release() {
            tasks.forEach({ $0.cancel() })
        }
        
        init(subscriberId: Int) {
            self.subscriptionId = subscriberId
        }
    }
    
    var tasks: [SubscriberTasks] = .init()
    
    public func registerTask(_ task: CancelType, for subscriber: SubscriberObject) {
        let subscriptionId = subscriber.subscriptionId
        lock.lock()
        defer { lock.unlock() }
        if let tasks = tasks.first(where: { $0.subscriptionId == subscriptionId }) {
            tasks.addTask(task)
        } else {
            let newTasks = SubscriberTasks.init(subscriberId: subscriptionId)
            newTasks.addTask(task)
            tasks.append(newTasks)
        }
    }
    
    public func cancelAndRelease(from subscriber: SubscriberObject) {
        let subscriptionId = subscriber.subscriptionId
        lock.execute {
            if let index = tasks.firstIndex(where: { $0.subscriptionId == subscriptionId }) {
                tasks[index].release()
                tasks.remove(at: index)
            }
        }
    }
}
