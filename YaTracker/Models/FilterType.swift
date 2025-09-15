//
//  FilterType.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 10.09.2025.
//

import Foundation

enum FilterType: CaseIterable, Codable {
    case all
    case today
    case completed
    case active
    
    var stringValue: String {
        return switch self {
        case .all: "Все трекеры"
        case .today: "Трекеры на сегодня"
        case .completed: "Завершенные"
        case .active: "Незавершенные"
        }
    }
}
