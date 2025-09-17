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
        weekdays.count == 7 ? NSLocalizedString("every_day", comment: "EveryDay") : weekdays.sorted().map { $0.shortName } .joined(separator: ", ")
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
        case .monday: NSLocalizedString("monday_short", comment: "")
        case .tuesday: NSLocalizedString("tuesday_short", comment: "")
        case .wednesday: NSLocalizedString("wednesday_short", comment: "")
        case .thursday: NSLocalizedString("thursday_short", comment: "")
        case .friday: NSLocalizedString("friday_short", comment: "")
        case .saturday: NSLocalizedString("saturday_short", comment: "")
        case .sunday: NSLocalizedString("sunday_short", comment: "")
        }
    }
    
    var longName: String {
        return switch self {
        case .monday: NSLocalizedString("monday", comment: "")
        case .tuesday: NSLocalizedString("tuesday", comment: "")
        case .wednesday: NSLocalizedString("wednesday", comment: "")
        case .thursday: NSLocalizedString("thursday", comment: "")
        case .friday: NSLocalizedString("friday", comment: "")
        case .saturday: NSLocalizedString("saturday", comment: "")
        case .sunday:  NSLocalizedString("sunday", comment: "")
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
