//
//  TrackerCategory.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import Foundation

struct TrackerCategory: Comparable, Hashable {
    static func < (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title < rhs.title
    }
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    let title: String
    let trackers: [Tracker]
}
