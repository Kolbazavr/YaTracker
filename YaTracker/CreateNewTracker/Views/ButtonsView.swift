//
//  ButtonsView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 11.08.2025.
//

import UIKit

final class ButtonsView: UIView {
    let horizontalSpacing: CGFloat = 8
    let padding: CGFloat = 16
    let buttonHeight: CGFloat = 60
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = horizontalSpacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(buttons: [UIButton], frame: CGRect = .zero) {
        super.init(frame: frame)
        
        buttons.forEach { hStack.addArrangedSubview($0) }
        addSubview(hStack)
                
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            hStack.heightAnchor.constraint(greaterThanOrEqualToConstant: buttonHeight)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
