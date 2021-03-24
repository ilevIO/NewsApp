//
//  ImageProvider.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation
import UIKit

struct ImageProvider {
    internal init(getImage: @escaping (String, ((UIImage?) -> Void)?) -> URLSessionTask?, getImageWithPriority: @escaping (String, ((UIImage?) -> Void)?, Float) -> URLSessionTask?, getCachedImage: @escaping (String) -> UIImage?, setImage: @escaping (UIImage?, String) -> Void) {
        self.getImage = getImage
        self.getImageWithPriority = getImageWithPriority
        self.getCachedImage = getCachedImage
        self.setImage = setImage
    }
    
    ///absoluteString or relativePath, completion(UIImage?), priority
    var getImage: (String, ((UIImage?) -> Void)?) -> URLSessionTask?
    var getImageWithPriority: (String, ((UIImage?) -> Void)?, Float) -> URLSessionTask?
    var getCachedImage: (String) -> UIImage?
    var setImage: (UIImage?, String) -> Void
    
    init() {
        let manager = ImageManager()
        self.getImage = { path, completion in
            return manager.getImage(forKey: path, completion: completion)
        }
        self.getImageWithPriority = { path, completion, priority in
            return manager.getImage(forKey: path, completion: completion, priority: priority)
        }
        self.getCachedImage = manager.getCachedImage(forKey:)
        self.setImage = manager.setImage(_:forKey:)
    }
}

extension ImageProvider {
    static var `default`: ImageProvider = {
        let manager = ImageManager()
        return ImageProvider(
            getImage: { path, completion in manager.getImage(forKey: path, completion: completion) },
            getImageWithPriority: manager.getImage(forKey:completion:priority:),
            getCachedImage: manager.getCachedImage(forKey:),
            setImage: manager.setImage(_:forKey:))
    }()
}
