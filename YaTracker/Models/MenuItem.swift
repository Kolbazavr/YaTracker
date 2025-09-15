//
//  MenuItem.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

enum MenuItem {
    case textField(placeholder: String, limit: Int, text: String?)
    case navigationLink(title: String, description: String?, destination: NavDestination)
    case weekDaySelector(toggle: Bool, day: WeekDay)
    case decorCollection(tracker: Tracker?, onDecorSelected: ((DecorType, Bool) -> Void)?)
    case categorySelector(categoryTitle: String, isSelected: Bool)
    
    var typeName: String {
        return switch self {
        case .textField: "textField"
        case .navigationLink: "navigationLink"
        case .weekDaySelector: "weekDay"
        case .decorCollection: "decorCollection"
        case .categorySelector: "categorySelector"
        }
    }
}
