//
//  Tracker.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let isPinned: Bool
}
