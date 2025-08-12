//
//  ButtonsView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 11.08.2025.
//

import UIKit

final class ButtonsView: UIView {
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(buttons: [UIButton], frame: CGRect = .zero) {
        super.init(frame: frame)
        
        buttons.forEach { hStack.addArrangedSubview($0) }
        addSubview(hStack)
                
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            hStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
