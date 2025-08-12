//
//  MenuHeaderView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 11.08.2025.
//

import UIKit

final class MenuHeaderView: UIView {
    let title = UILabel()
    let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        title.textColor = .ypBlack
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.textAlignment = .center
        title.text = "Header test"
        
        hStackView.addArrangedSubview(title)
        
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStackView)
        
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
}
