//
//  TrackerCell.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapTrackerCell(with tracker: Tracker)
}

final class TrackerCellCard: UICollectionViewCell {
    
    static let reuseIdentifier = "SuperUniqueIdentifierForTrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    private var tracker: Tracker?
    private var isCompletedToday: Bool = false
    private var isPinned: Bool = false
    
    private lazy var colorBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var emojiCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypEmojiBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .pin))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func trackerButtonTapped() {
        guard let tracker else { return }
        delegate?.didTapTrackerCell(with: tracker)
    }
    
    func configure(with tracker: Tracker, isCompletedToday: Bool, daysCompleted: Int, enableButton: Bool) {
        self.tracker = tracker
        colorBackgroundView.backgroundColor = UIColor(hexString: tracker.colorHex)
        trackerNameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        isPinned = tracker.isPinned
        pinImageView.isHidden = !isPinned
        
        doneButton.backgroundColor = UIColor(hexString: tracker.colorHex, alpha: isCompletedToday ? 0.3 : 1.0)
        doneButton.setImage(UIImage(resource: isCompletedToday ? .cellCheckMark : .cellPlus), for: .normal)
        doneButton.tintColor = .ypWhite
        doneButton.isEnabled = enableButton
        daysCounterLabel.text = daysCompleted.dayStringRU
    }
    
    private func setupUI() {
        colorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorBackgroundView)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCircleView.addSubview(emojiLabel)
        
        let emojiStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [emojiCircleView, UIView(), pinImageView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            return stackView
        }()
        
        let footerStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [daysCounterLabel, doneButton])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
            stackView.isLayoutMarginsRelativeArrangement = true
            return stackView
        }()
        
        let cardStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [emojiStackView, trackerNameLabel])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
            stackView.isLayoutMarginsRelativeArrangement = true
            return stackView
        }()
        
        colorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        colorBackgroundView.addSubview(cardStackView)
        
        let cellStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [colorBackgroundView, footerStackView])
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellStackView)
        
        NSLayoutConstraint.activate([
            emojiCircleView.widthAnchor.constraint(equalToConstant: 24),
            emojiCircleView.heightAnchor.constraint(equalToConstant: 24),
            
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiCircleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiCircleView.centerYAnchor),
            
            cardStackView.topAnchor.constraint(equalTo: colorBackgroundView.topAnchor),
            cardStackView.leadingAnchor.constraint(equalTo: colorBackgroundView.leadingAnchor),
            cardStackView.trailingAnchor.constraint(equalTo: colorBackgroundView.trailingAnchor),
            cardStackView.bottomAnchor.constraint(equalTo: colorBackgroundView.bottomAnchor),
            
            colorBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            
            cellStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
}
