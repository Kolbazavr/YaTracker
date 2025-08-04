//
//  Tracker.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import Foundation

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [String: String]
}
