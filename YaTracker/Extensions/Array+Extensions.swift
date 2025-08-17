//
//  Set+Extensions.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 14.08.2025.
//

import Foundation

extension Array where Element == WeekDay {
    var bitmask: Int16 { reduce(0) { $0 | $1.bitValue } }
}
