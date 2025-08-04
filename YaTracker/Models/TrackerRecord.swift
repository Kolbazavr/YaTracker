//
//  TrackerRecord.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import Foundation

struct TrackerRecord: Codable {
    let trackerId: UUID
    let completionDate: Date
}
