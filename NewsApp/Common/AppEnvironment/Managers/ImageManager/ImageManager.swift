//
//  ImageManager.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import UIKit

class ImageManager {
    var cache = Cache<String, Data>()
    var lock = NSLock()
    var requests: [URL: [((UIImage?) -> Void)?]] = [:]
    
    func getLocalStoredImageData(forKey key: String) -> Data? {
        if let data = Current.localStorage.load(entityName: CoreDataEntities.localImage, predicate: .init(format: "\(CoreDataLocalImage.url) == %@", key))?
            .first?
            .value(forKey: CoreDataLocalImage.imageData) as? Data {
            self.insertImage(data, forKey: key)
            return data
        }
        return nil
    }
    
    func saveImageLocally(image: UIImage, urlKey: String) {
        guard let imageData = image.pngData() else { return }
        Current.localStorage.save(
            entityFields: [
                CoreDataLocalImage.url: urlKey,
                CoreDataLocalImage.imageData: imageData,
                CoreDataLocalImage.lastAccess: Date()
            ],
            to: CoreDataEntities.localImage
        )
    }
    
    func getCachedImage(forKey key: String) -> UIImage? {
        guard let data = cache.value(forKey: key) ?? getLocalStoredImageData(forKey: key) else { return nil }
        return UIImage(data: data)
    }
    
    func getImage(forKey key: String, completion: ((UIImage?) -> Void)?, priority: Float = URLSessionTask.defaultPriority) -> URLSessionTask? {
        let urlKey = key
        
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
                    self?.lock.execute { self?.requests.removeValue(forKey: url) }
                    completion?(nil)
                    return
                }
                self?.insertImage(data, forKey: urlKey)
                self?.saveImageLocally(image: image, urlKey: urlKey)
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
    
    @discardableResult
    private func insertImage(_ data: Data?, forKey key: String) -> Data? {
        if let data = data {
            cache.insert(data, forKey: key)
        }
        return data
    }
    
    func setImage(_ image: UIImage?, forKey key: String) {
        if let image = image, let data = image.pngData() { cache.insert(data, forKey: key) }
        else { cache.removeValue(forKey: key) }
    }
}

