//
//   DoneButton.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

final class DoneButton: UIButton {
    override var isEnabled: BooleanLiteralType {
        didSet {
            super.backgroundColor = isEnabled ? .ypBlackDay : .ypGray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        super.backgroundColor = isEnabled ? .ypBlackDay : .ypGray
        super.layer.cornerRadius = 16
        super.tintColor = .ypWhite
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
