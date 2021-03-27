//
//  NewsRequests.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import Foundation

extension APIManager {
    func getEverything(
        parameters: Endpoints.News.GetEverything.Parameters,
        completion: ((Endpoints.News.GetEverything.Response?, Error?) -> Void)?) -> URLSessionTask? {
        apiClient.request(Endpoints.News.GetEverything(parameters: parameters)) { data, response, error in
            if let error = self.handleError(data: data, response: response, error: error) {
                completion?(nil, error)
            } else {
                if let data = data, !data.isEmpty {
                    let response = try! JSONDecoder().decode(Endpoints.News.GetEverything.Response.self, from: data)
                    completion?(response, error)
                } else {
                    completion?(nil, error ?? APIError(timestamp: nil, status: "0", message: "No data", type: nil))
                }
            }
        }
    }
}
