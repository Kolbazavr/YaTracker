//
//  SearchTextField.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

final class SearchTextField: UITextField {
    private let maxLength: Int
    private let onSearchAction: ((String) -> Void)?
    
    init(placeholder: String? = nil, maxLength: Int, onSearchAction: @escaping ((String) -> Void)) {
        self.maxLength = maxLength
        self.onSearchAction = onSearchAction
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
        textColor = .ypGray
        backgroundColor = .ypBackgroundGray
        layer.cornerRadius = 10
        setIcon(UIImage(resource: .magniGlass), spacing: 8)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func textDidChange() {
        onSearchAction?(self.text ?? "")
    }
}

extension SearchTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard maxLength > 0 else { return true }
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText)
        else { return false }
        
        let newText = currentText.replacingCharacters(in: textRange, with: string)
        return newText.count <= maxLength
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        onSearchAction?("")
        return true
    }
}
