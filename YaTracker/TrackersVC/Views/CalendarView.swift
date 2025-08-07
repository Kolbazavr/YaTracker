//
//  CalendarView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

final class CalendarView: UIView {
    
    weak var calendarViewDelegate: CalendarViewDelegate?

    private var calendarSelection: UICalendarSelectionMultiDate?
    private var currentlySelectedDate: Date?

    private let calendar = UICalendarView()
    private let calendarCurrent = Calendar.current
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectDate(_ date: Date) {
        let components = calendarCurrent.dateComponents([.year, .month, .day], from: date)
        calendar.setVisibleDateComponents(components, animated: true)
        calendarSelection?.setSelectedDates([components], animated: true)
    }
    
    private func configure() {
        let background = createBlurView()
        background.layer.cornerRadius = 13
        background.layer.masksToBounds = true
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        
        isHidden = true
        calendarSelection = UICalendarSelectionMultiDate(delegate: self)
        calendar.selectionBehavior = calendarSelection!
        calendar.backgroundColor = .ypWhite.withAlphaComponent(0.8)
        
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.tintColor = .ypBlue
        calendar.layer.shadowColor = UIColor.black.cgColor
        calendar.layer.shadowOffset = CGSize(width: 0, height: 10)
        calendar.layer.shadowOpacity = 0.1
        calendar.layer.shadowRadius = 12
        calendar.layer.cornerRadius = 13
        calendar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(calendar)
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: calendar.topAnchor),
            background.leadingAnchor.constraint(equalTo: calendar.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: calendar.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: calendar.bottomAnchor),
            
            calendar.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            calendar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            calendar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            calendar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
    
    func createBlurView() -> UIView {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurView.alpha = 0.8
        return blurView
    }
}

extension CalendarView: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        selection.setSelectedDates([dateComponents], animated: true)
        let date = Calendar.current.date(from: dateComponents)!
        calendarViewDelegate?.didSelectDate(date)
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        selection.setSelectedDates([dateComponents], animated: true)
        let date = Calendar.current.date(from: dateComponents)!
        calendarViewDelegate?.didSelectDate(date)
    }
}
