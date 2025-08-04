//
//  CancelButton.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

final class CancelButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        super.setTitleColor(.ypRed, for: .normal)
        super.backgroundColor = .ypWhite
        super.layer.cornerRadius = 16
        super.tintColor = .ypRed
        super.layer.borderColor = UIColor.ypRed.cgColor
        super.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
