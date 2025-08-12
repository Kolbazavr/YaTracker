//
//  MenuDecorCell.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 10.08.2025.
//

import UIKit

final class MenuDecorCell: UITableViewCell {
    
    static let reuseIdentifier = "MenuCellToShoveCollectionViewInto"
    
    private var collectionView = DecorCollectionView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(collectionDelegate: DecorCollectionViewDelegate) {
        collectionView.decorDelegate = collectionDelegate
        backgroundColor = .ypWhite
        selectionStyle = .none
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        collectionView.reloadData()
    }
}
