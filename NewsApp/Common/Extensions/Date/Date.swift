//
//  Date.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import Foundation

extension Date {
    ///Returns whether the date is more recent than from given days
    func isWithinPeriod(days: TimeInterval) -> Bool {
        distance(to: .init()) < days * 24 * 60 * 60
    }
}
