//
//  NewTrackerTextField.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

final class NewTrackerTextField: UITextField {
    
    var maxLength: Int
    
    private var overLimit: Bool { text?.count ?? 0 > maxLength }
    private let onTypingAction: ((String, Bool) -> Void)?
    
    init(placeholder: String? = nil, maxLength: Int = 38, onTypingAction: @escaping ((String, Bool) -> Void)) {
        self.maxLength = maxLength
        self.onTypingAction = onTypingAction
        super.init(frame: .zero)
        self.placeholder = placeholder
        setSearchAction()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSearchAction() {
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func configure() {
        delegate = self
        
        clearButtonMode = .whileEditing
        autocapitalizationType = .none
        autocorrectionType = .no
        clearsOnBeginEditing = true
        font = .systemFont(ofSize: 17, weight: .regular)
        textColor = .ypBlackDay
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func textDidChange() {
        onTypingAction?(self.text ?? "", overLimit)
    }
}

extension NewTrackerTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard maxLength > 0 else { return true }
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText)
        else { return false }
        
        let newText = currentText.replacingCharacters(in: textRange, with: string)
        return newText.count <= maxLength + 1
    }
}
