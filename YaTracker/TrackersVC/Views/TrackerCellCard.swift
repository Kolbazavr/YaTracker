//
//  TrackerCell.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapTrackerCell(with trackerID: UUID, at indexPath: IndexPath)
}

final class TrackerCellCard: UICollectionViewCell {
    static let reuseIdentifier = "SuperUniqueIdentifierForTrackerCell"
    
//    weak var delegate: TrackerCellDelegate?
    
    private var trackerID: UUID?
    private var indexPath: IndexPath?
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
        view.circlize()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: TrackerCellViewModel) {
        colorBackgroundView.backgroundColor = .colorSelection118
        trackerNameLabel.text = "Some tracker name"
        emojiLabel.text = "🏃‍♂️"
        isPinned = true
        pinImageView.isHidden = !isPinned
    }
    
    private func setupUI() {
        colorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorBackgroundView)
        
        emojiCircleView.addSubview(emojiLabel)
        
        let hStackView = UIStackView(arrangedSubviews: [emojiCircleView, pinImageView])
        hStackView.axis = .horizontal
        hStackView.distribution = .equalSpacing
        
        let vStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [hStackView, trackerNameLabel])
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            emojiCircleView.heightAnchor.constraint(equalToConstant: 24),
            
            colorBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            vStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
}
