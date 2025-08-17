//
//  DecorCell.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 09.08.2025.
//

import UIKit

final class DecorCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MegaUltraTurboSuperLongUniqueDecorCellIdentifier"
    
    override var isSelected: Bool { didSet { toggleSelected() } }
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selectionRectangle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with decorType: DecorType) {
        switch decorType {
        case .emoji(let emoji): setEmoji(emoji)
        case .colorHex(let hex): setColor(from: hex)
        }
    }
    
    func toggleSelected() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromTop, .curveEaseInOut]
        UIView.transition(with: selectionRectangle, duration: 0.3, options: transitionOptions) { [weak self] in
            self?.selectionRectangle.alpha = (self?.isSelected ?? false) ? 1 : 0
        }
    }
    
    private func setEmoji(_ emoji: String) {
        emojiLabel.text = emoji
        selectionRectangle.backgroundColor = .ypLightGray
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: selectionRectangle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: selectionRectangle.centerYAnchor)
        ])
    }
    
    private func setColor(from hexColor: String) {
        colorView.backgroundColor = UIColor(hexString: hexColor)
        selectionRectangle.layer.borderWidth = 3
        selectionRectangle.layer.borderColor = UIColor(hexString: hexColor, alpha: 0.3)?.cgColor
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: selectionRectangle.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: selectionRectangle.centerYAnchor)
        ])
    }
    
    private func setup() {
        contentView.addSubview(selectionRectangle)
        
        NSLayoutConstraint.activate([
            selectionRectangle.widthAnchor.constraint(equalToConstant: 52),
            selectionRectangle.heightAnchor.constraint(equalToConstant: 52),
            selectionRectangle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionRectangle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
