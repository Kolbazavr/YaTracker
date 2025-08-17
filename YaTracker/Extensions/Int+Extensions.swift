//
//  Int+Extensions.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 04.08.2025.
//

import Foundation

extension Int {
    var dayStringRU: String {
        let mod10 = self % 10
        let mod100 = self % 100
        
        if mod10 == 1 && mod100 != 11 {
            return "\(self) день"
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            return "\(self) дня"
        } else {
            return "\(self) дней"
        }
    }
}

extension Int16 {
    var weekDays: Set<WeekDay> { Set(WeekDay.allCases.filter { self & $0.bitValue != 0 }) }
}
