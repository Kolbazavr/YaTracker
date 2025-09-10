//
//  EyesKillerVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.08.2025.
//

import UIKit

final class EyesCrackerView: UIView {
    private let itemView: Items
    private let itemsCount: Int
    private let itemSize: CGFloat
    private let rotationDirection: CGFloat
    private let containerView = UIView()
    
    enum Items: CaseIterable {
        case stars
        case smile
        case practoLogo
        
        var view: UIView {
            return switch self {
            case .stars: {
                let starsLabel = UILabel()
                starsLabel.text = "✨"
                return starsLabel
            }()
            case .smile: {
                let smileLabel = UILabel()
                smileLabel.text = "🥰"
                return smileLabel
            }()
            case .practoLogo: UIImageView(image: UIImage(resource: .launchScreenLogo))
            }
        }
    }
    
    init(frame: CGRect, itemView: Items, itemsCount: Int = 12, itemSize: CGFloat = 20, rotationDirection: CGFloat = 1) {
        self.itemView = itemView
        self.itemsCount = itemsCount
        self.itemSize = itemSize
        self.rotationDirection = rotationDirection
        super.init(frame: frame)
        
        setup()
        startRotation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
    
    private func setup() {
        containerView.frame = bounds
        addSubview(containerView)
        
        let radius = min(bounds.width, bounds.height) / 2 - itemSize
        
        for i in 0..<itemsCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(itemsCount))
            let x = bounds.midX + radius * cos(angle)
            let y = bounds.midY + radius * sin(angle)
            
            let newItemView = itemView.view
            
            newItemView.frame = CGRect(x: 0, y: 0, width: itemSize, height: itemSize)
            newItemView.center = CGPoint(x: x, y: y)

            containerView.addSubview(newItemView)
        }
        
        for case let label as UILabel in containerView.subviews {
            label.font = UIFont.systemFont(ofSize: itemSize)
            label.textAlignment = .center
        }
    }
    
    private func startRotation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: Double.pi * 2 * rotationDirection)
        rotation.duration = 8.0
        rotation.repeatCount = .infinity
        containerView.layer.add(rotation, forKey: "rotation")
        
        let counterRotation = CABasicAnimation(keyPath: "transform.rotation")
        counterRotation.toValue = NSNumber(value: Double.pi * 2 * -rotationDirection)
        counterRotation.duration = 8.0
        counterRotation.repeatCount = .infinity
        containerView.subviews.forEach { $0.layer.add(counterRotation, forKey: "counterRotation") }
    }
}
