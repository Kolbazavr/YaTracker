//
//  DecorCollectionView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 09.08.2025.
//

import UIKit

protocol DecorCollectionViewDelegate: AnyObject {
    func didTapedOnDecor(_ decor: DecorType, wasSelected: Bool)
}

final class DecorCollectionView: UICollectionView {
    
    var onDecorSelected: ((DecorType, Bool) -> Void)?
    var preSelectedDecor: [DecorType] = []
    
    private let allItems: [[DecorType]]
    private let headers: [String] = ["Emoji", "Цвет"]
    
    init(emojis: [DecorType] = DecorType.allEmojis, colorsHex: [DecorType] = DecorType.allColors) {
        self.allItems = [emojis, colorsHex]
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        allowsSelection = false
        allowsMultipleSelection = true
        delegate = self
        dataSource = self
        register(DecorCell.self, forCellWithReuseIdentifier: DecorCell.reuseIdentifier)
        
        register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        
        isScrollEnabled = false
    }
}

extension DecorCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selected = indexPathsForSelectedItems {
            for selectedIndexPath in selected where selectedIndexPath.section == indexPath.section && selectedIndexPath != indexPath {
                deselectItem(at: selectedIndexPath, animated: false)
            }
        }
        onDecorSelected?(allItems[indexPath.section][indexPath.item], true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        onDecorSelected?(allItems[indexPath.section][indexPath.item], false)
    }
}

extension DecorCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        allItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allItems[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DecorCell.reuseIdentifier, for: indexPath) as? DecorCell else {
            fatalError("This should be registered DecorCell")
        }
        let item = allItems[indexPath.section][indexPath.item]
        let isSelected = preSelectedDecor.contains { $0 == item }
        cell.configure(with: item)
        
        if isSelected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewHeader.reuseIdentifier, for: indexPath) as? CollectionViewHeader else {
            preconditionFailure("Fairly certain this won't ever happen")
        }
        header.configure(with: headers[indexPath.section])
        return header
    }
}

extension DecorCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { CGSize(width: 52, height: 52) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 5 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
}
