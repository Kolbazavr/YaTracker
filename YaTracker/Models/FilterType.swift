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
        case .all: NSLocalizedString("all_trackers", comment: "AllTrackers")
        case .today: NSLocalizedString("trackers_for_today", comment: "TodayTrackers")
        case .completed: NSLocalizedString("completed", comment: "CompletedTrackers")
        case .active: NSLocalizedString("unfinished", comment: "UnfinishedTrackers")
        }
    }
}
