//
//  DateTextField.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

final class DateTextField: UITextField {
    
    weak var dateTextFieldDelegate: DateTextFieldDelegate?
    
    private var isBlocked: Bool = false
    
    private let maxLength: Int
    private let onSearchAction: ((Date) -> Void)?
    private let defaultTextColor: UIColor = .ypBlack
    
    init(maxLength: Int, onSearchAction: @escaping ((Date) -> Void)) {
        self.maxLength = maxLength
        self.onSearchAction = onSearchAction
        super.init(frame: .zero)
        configure()
        setDate(Date())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDate(_ date: Date) {
        self.text = DateFormatter.trackerDateFormat.string(from: date)
        resignFirstResponder()
    }
    
    private func configure() {
        delegate = self
        
        autocapitalizationType = .none
        autocorrectionType = .no
        clearsOnBeginEditing = true
        textAlignment = .center
        keyboardType = .numberPad
        font = .systemFont(ofSize: 17, weight: .regular)
        textColor = defaultTextColor
        backgroundColor = .ypBackgroundDay
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension DateTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let dateTextFieldDelegate else { return true }
        if !dateTextFieldDelegate.isCalendarVisible {
            dateTextFieldDelegate.showCalendar()
            resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText),
              !isBlocked
        else { return false }
        
        var newText = currentText.replacingCharacters(in: textRange, with: string).replacingOccurrences(of: ".", with: "")
        
        if newText.count > 6 {
            return false
        }
        
        if newText.count > 4 {
            newText.insert(".", at: newText.index(newText.startIndex, offsetBy: 4))
        }
        
        if newText.count > 2 {
            newText.insert(".", at: newText.index(newText.startIndex, offsetBy: 2))
        }
        
        textField.text = newText
        
        if newText.count == 8 {
            if let date = DateFormatter.trackerDateFormat.date(from: newText) {
                onSearchAction?(date)
                resignFirstResponder()
            } else {
                isBlocked = true
                textField.textColor = .ypRed
                textField.text = "Nope"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    textField.textColor = self?.defaultTextColor
                    textField.text = ""
                    self?.isBlocked = false
                }
            }
        }
        return false
    }
}
