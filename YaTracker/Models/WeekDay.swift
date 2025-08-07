//
//  WeekDays.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import Foundation

enum WeekDay: String, CaseIterable, Comparable {
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        return switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday:  "Вс"
        }
    }
    
    private var sortOrder: Int {
        return switch self {
        case .monday: 0
        case .tuesday: 1
        case .wednesday: 2
        case .thursday: 3
        case .friday: 4
        case .saturday: 5
        case .sunday:  6
        }
    }
}

extension WeekDay {
    init(from date: Date) {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        switch weekdayNumber {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default:
            assertionFailure("WTF with day number: \(weekdayNumber). It will be MoooOOOOoonDDaaaaaY!")
            self = .monday
        }
    }
}
