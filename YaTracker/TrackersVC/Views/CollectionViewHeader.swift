//
//  TrackerCellSuplePuple.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 01.08.2025.
//

import UIKit

final class CollectionViewHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "TrackerCellSuplePuple"
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlackDay
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with category: TrackerCategory) {
        label.text = category.title
    }
    
    private func setupViews() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }
    
    
}
