//
//  FiltersButton.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.09.2025.
//

import UIKit

final class FiltersButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        super.setTitleColor(.ypWhite, for: .normal)
        super.backgroundColor = .ypBlue
        super.layer.cornerRadius = 16
        super.tintColor = .ypWhite
        super.setTitle("Фильтры", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
