//
//  TrackerCategoryCoreData+Extensions.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import Foundation

extension TrackerCategoryCoreData {
    func toStruct() -> TrackerCategory {
        TrackerCategory(
            title: title ?? "",
            trackers: (trackers?.allObjects as? [TrackerCoreData])?.compactMap { $0.toStruct() } ?? []
        )
    }
}
