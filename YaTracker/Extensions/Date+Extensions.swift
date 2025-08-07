//
//  Date+Extensions.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import Foundation

extension Date {
    var onlyDate: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}

extension DateFormatter {
    static let trackerDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
}
