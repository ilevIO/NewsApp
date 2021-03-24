//
//  ImageManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import UIKit
import Combine

class ImageManager {
    var cache = Cache<String, Data>()
    var lock = NSLock()
    var requests: [URL: [((UIImage?) -> Void)?]] = [:]
    
    func getCachedImage(forKey key: String) -> UIImage? {
        guard let data = cache.value(forKey: key) else { return nil }
        return UIImage(data: data)
    }
    
    func getImage(forKey key: String, completion: ((UIImage?) -> Void)?, priority: Float = URLSessionTask.defaultPriority) -> URLSessionTask? {
        let urlKey = key//.hasPrefix("http") ? key : baseImageUrl.absoluteString.appending(key)
        if let image = getCachedImage(forKey: urlKey) {
            completion?(image)
            return nil
        }
        guard let url = URL(string: urlKey) else { completion?(nil); return nil }
        
        self.lock.execute {
            if let _ = requests[url] {
                requests[url]?.append(completion)
            } else {
                requests[url] = [completion]
            }
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data {
                guard let image = UIImage(data: data) else {
                    //TODO: investigate
                    //print(url.absoluteString)
                    self?.lock.execute { self?.requests.removeValue(forKey: url) }
                    completion?(nil)
                    return
                }
                self?.insertImage(data, forKey: urlKey)
                self?.lock.execute {
                    self?.requests[url]?.forEach({ $0?(image) })
                    self?.requests.removeValue(forKey: url)
                }
                completion?(image)
            } else {
                completion?(nil)
            }
        }
        task.priority = priority
        task.resume()
        return task
    }
    
    func getImage(forKey key: String) -> AnyPublisher<UIImage?, Never> {
        if let image = getCachedImage(forKey: key) {
            return Just(image).eraseToAnyPublisher()
        }
        let urlKey = key//.hasPrefix("http") ? key : baseImageUrl.absoluteString.appending(key)
        guard let url = URL(string: urlKey)
        else { return Just(nil).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map(UIImage.init)
            .map { [weak self] in self?.insertImage($0, forKey: urlKey) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    private func insertImage(_ data: Data?, forKey key: String) -> Data? {
        if let data = data {
            cache.insert(data, forKey: key)
        }
        return data
    }
    
    @discardableResult
    private func insertImage(_ image: UIImage?, forKey key: String) -> UIImage? {
        if image != nil {
            //cache.insert(image, forKey: key)
        }
        return image
    }
    
    func setImage(_ image: UIImage?, forKey key: String) {
        if let image = image, let data = image.pngData() { cache.insert(data, forKey: key) }
        else { cache.removeValue(forKey: key) }
    }
}

