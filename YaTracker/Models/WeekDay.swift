//
//  WeekDays.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import Foundation

enum WeekDay: Int, CaseIterable, Comparable {
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    static func daysString(from weekdays: Set<WeekDay>) -> String {
        weekdays.count == 7 ? "Каждый день" : weekdays.sorted().map { $0.shortName } .joined(separator: ", ")
    }
    
    var bitValue: Int16 { 1 << self.sortOrder }
    
    init(from date: Date) {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        self.init(rawValue: weekdayNumber)!
    }
    
    case monday = 2
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday = 1
    
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
    
    var longName: String {
        return switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday:  "Воскресенье"
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
