//
//  TrackerCoreData+Extensions.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import Foundation

extension TrackerCoreData {
    func toStruct() -> Tracker {
        Tracker(
            id: id ?? UUID(),
            name: name ?? "",
            colorHex: colorHex ?? "",
            emoji: emoji ?? "",
            schedule: (try? JSONDecoder().decode([WeekDay].self, from: schedule ?? Data())) ?? [],
            isPinned: isPinned
        )
    }
}
